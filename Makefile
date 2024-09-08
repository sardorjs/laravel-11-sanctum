include .env		## Include .env to use variables inside of it -> $(DB_DATABASE)
default: up			## The command by default: make -> default = make up

#####################################################
#                                                   #
#               ARGUMENTS/VARIABLES                 #
#                                                   #
#####################################################
## Current timestamp - 2024-08-22_16-30-53
TIMESTAMP = $(shell date -u +%Y-%m-%d_%H-%M-%S)
LAST_SQL_BACKUP_FILE = $(shell ls -t backups | head -n 1)		## Find latest SQL file from backups/ folder

# .PHONY indicates to make that the listed targets (up, down, migrate, etc.)
# are not filenames, just commands. This prevents conflicts
# with files that might accidentally have the same names as targets.
.PHONY: up up-force down down-v-prune cli db db-root restore-db backup-db cache-clear config-clear prune-all df migrate seed migrate-seed test logs-app logs-db restart


#####################################################
#                                                   #
#                     Docker                        #
#                                                   #
#####################################################

up:					## Start all containers
	docker compose up -d --build

up-force:			## Start the containers with force rebuild
	docker compose -f $(APP_DOCKER_COMPOSE) up -d --build

down:				## Stop and remove all containers
	docker compose down

down-v-prune:		## Stop and remove all containers (with volume)
	docker compose -f $(APP_DOCKER_COMPOSE) down --volumes

cli:				## Open a bash shell in the app container and create an alias 'll' for 'ls -lah'
	docker compose exec -it app bash -c "echo 'alias ll=\"ls -lah\"' >> ~/.bashrc && bash"

db:					## Logging in to MySQL as a created user
	docker compose exec -it db bash -c "mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE)"

db-root:			## Logging in to MySQL as root
	docker compose -f $(APP_DOCKER_COMPOSE) exec -it db bash -c "mysql -h 127.0.0.1 -P 3306 -u root -p$(DB_ROOT_PASSWORD)"

df:					## Viewing memory usage values in Docker
	docker system df

prune-all:			## Complete cleaning - Volumes, Images, Cache, System configurations
	docker image prune -af
	docker system prune -af
	docker volume prune -af
	docker builder prune -af
	docker system df
	#rm -rf .docker/mysql/data

logs-nginx:			## View logs for the Nginx Container
	docker compose logs -f nginx

logs-app:			## View logs for the Web Container
	docker compose logs -f app

logs-db:			## View logs for the Database Container
	docker compose logs -f db

restart:			## Restart all containers
	docker compose restart


#####################################################
#                                                   #
#                    Application                    #
#                                                   #
#####################################################

import-db:			## Import latest SQL file from backups/ folder
	cat backups/$(LAST_SQL_BACKUP_FILE) | docker compose exec -T db mysql -u $(DB_USERNAME) --password=$(DB_PASSWORD) $(DB_DATABASE)

last-sql-file:		## Last SQL Backup File from backups/ folder
	@echo $(LAST_SQL_BACKUP_FILE)

export-db:			## Export SQL file to backups/ folder - Backup Database
	docker compose exec db mysqldump -u root -p$(DB_ROOT_PASSWORD) $(DB_DATABASE) > "backups/app-$(TIMESTAMP).sql"

cache-clear:		## Clear all cache of Laravel Project
	docker compose exec -it app bash -c "php artisan cache:clear"
	docker compose exec -it app bash -c "php artisan config:clear"
	docker compose exec -it app bash -c "php artisan event:clear"
	docker compose exec -it app bash -c "php artisan route:clear"
	docker compose exec -it app bash -c "php artisan view:clear"
	docker compose exec -it app bash -c "php artisan schedule:clear-cache"
	docker compose exec -it app bash -c "php artisan config:cache"

config-clear:		## Clear config of Laravel Project
	docker compose exec -it app bash -c "php artisan config:clear"
	docker compose exec -it app bash -c "php artisan config:cache"

migrate:			## Migrate files of Laravel Project
	docker compose exec -it app bash -c "php artisan migrate"

seed:				## Run seeds of Laravel Project
	docker compose exec -it app bash -c "php artisan db:seed"

migrate-seed:		## Migrate files and run seeds of Laravel Project
	docker compose exec -it app bash -c "php artisan migrate --seed"

test:				## Run tests of Laravel Project
	docker compose exec -it app bash -c "php artisan test"

help:				## Use `make help` to see a list of all available commands with descriptions
	@echo "Available commands:"
	@echo "    up               Start the containers"
	@echo "    up-force         Start the containers with force rebuild"
	@echo "    down             Stop and remove all containers"
	@echo "    down-v-prune     Terminate all containers and delete images, including volumes"
	@echo "    cli              Open a bash shell in the app container"
	@echo "    db               Log in to MySQL as a created user"
	@echo "    db-root          Log in to MySQL as root"
	@echo "    restore-db       Restore the latest SQL backup from the backups/ folder"
	@echo "    backup-db        Export the SQL file to the backups/ folder"
	@echo "    cache-clear      Clear all Laravel caches"
	@echo "    config-clear     Clear and cache Laravel configuration"
	@echo "    prune-all        Complete cleaning of Docker system (images, containers, volumes)"
	@echo "    df               View Docker system disk usage"
	@echo "    migrate          Run Laravel migrations"
	@echo "    seed             Run Laravel seeders"
	@echo "    migrate-seed     Run Laravel migrations and seeders"
	@echo "    test             Run Laravel tests"
	@echo "    logs-app         View logs for the app container"
	@echo "    logs-db          View logs for the db container"
	@echo "    restart          Restart all containers"
