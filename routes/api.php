<?php

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::prefix('/tokens')->group(function(){

    Route::post('/create', function(Request $request){
        $user = $request->user() ?? User::factory()->create();
        $token = $user->createToken($request->token_name);

        return ['token' => $token->plainTextToken];
    });

    Route::post('/create-with-superadmin-abilities', function(Request $request){
        $user = $request->user() ?? User::factory()->create();
        $token = $user->createToken($request->token_name, ['admin:superadmin']);

        return ['token' => $token->plainTextToken];
    });

    Route::get('/has-superadmin-abilities', function(){
        $user = User::where('id', 1)->first();
        dd($user->tokens, 'admin:superadmin', $user->currentAccessToken(),  $user->tokenCan('admin:superadmin'));
        if(! $user->tokenCan('admin:superadmin')){
            return response()->json([
                'success' => false,
                    'data' => [
                        'text' => 'Ooops! You are not superadmin!'
                    ]
                ], 403);
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'text' => 'Congrats! You are superadmin!'
            ]
        ], 200);

    });
    
});

