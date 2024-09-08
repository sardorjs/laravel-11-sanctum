# Setup | Laravel 11 Project in Docker

Follow the steps below to set up and run this Laravel 11 Project in Docker.

## Prerequisites

Ensure you have the following installed on your system:
- Docker
- Docker Compose
- Git

## 1. Clone the Repository

Start by cloning the repository to your local machine:

```bash
git clone https://github.com/sardorjs/laravel-11-docker.git
cd laravel-11-docker
```

## 2. Copy the `.env` File

Create the environment configuration by copying the example `.env` file:

```bash
cp .env.example .env
```

### Configure Database Credentials

Open the `.env` file and update the following variables with your database information:

```env
DB_DATABASE=laravel
DB_USERNAME=project_user
DB_PASSWORD=14ufFIjgfoB32fkS3
DB_ROOT_PASSWORD=549JryqIfS483FG
```

## 3. Start the Containers

Bring up the containers to initialize the environment:

```bash
make up
```



## 4. Install Dependencies

Once the containers are running, enter the container and install the PHP dependencies:

```bash
make cli
composer install
```

## 5. Set Directory Permissions

Ensure the `storage` and `bootstrap/cache` directories are writable by running:

```bash
make cli
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
```

## 6. Generate Application Key

Generate the application key:

```bash
make cli
php artisan key:generate
```

## 7. Cache Configurations

Update the `.env` variables in the configuration file:

```bash
make config-clear
```

## 8. Run Database Migrations

Apply the migrations to set up the database schema:

```bash
make cli
php artisan migrate
```

## 9. Access the Application

The application should now be accessible at [http://localhost](http://localhost).

## Additional Notes

- To stop the application, run:

```bash
make down
```

- If you need to rebuild the containers, use:

```bash
make up-force
```

- Use make help to see a list of all available commands with descriptions:

```bash
make help
```

That's it! Your Laravel project should now be running smoothly.
