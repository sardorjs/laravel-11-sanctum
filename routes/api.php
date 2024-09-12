<?php

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('test', function (){

    $arr = [
        '1' => 'hello',
        1 => 'hi',
        2 => 'bye',
    ];
    $var = '1';

    return response()->json($arr[$var]);
});

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

    Route::post('/create-with-abilities', function(Request $request){
        $user = User::factory()->create();
        $abilities = [
            0 => [
                'user'
            ],
            1 => [
                'check-status'
            ],
            2 => [
                'check-status',
                'place-orders'
            ],
        ];

        $abilityId = $request->ability_id ?? 0;

        $chosenAbility = array_key_exists($abilityId, $abilities) ? $abilities[$abilityId] : $abilities[0];

        $token = $user->createToken('access_token', $chosenAbility, now()->addMinutes(2))->plainTextToken;

        return ['token' => $token];
    });

    Route::get('/has-superadmin-abilities', function(){
        $user = User::where('id', 1)->first();
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

    Route::delete('/revoke-all', function (Request $request){
        // revoke all tokens
        $request->user()->tokens()->delete();

        return response()->json([
            'success' => true,
            'data' => [
                'text' => 'All Tokens Revoked!'
            ]
        ]);
    })->middleware(['auth:sanctum']);

    Route::delete('/revoke-current', function(Request $request){
        // revoke current
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'data' => [
                'text' => 'Current Token Revoked!'
            ]
        ]);
    })->middleware(['auth:sanctum']);

    


});

Route::post('/token-can', function (Request $request) {

    $tokenCan = 'check-status';
    $message = $request->user()->tokenCan($tokenCan) ? 'Yes, Token Can!' : 'No, Token Cannot!';

    return response()->json([
        'message' => $message,
    ]);

})->middleware('auth:sanctum');

Route::get('/orders', function (){
   // Token has both "check-status" and "place-orders" abilities ...

    return response()->json([
       'success' => true,
       'data' => [
           'text' => 'Congrats! You have both check-status and place-orders abilities!'
       ],
    ]);
})->middleware(['auth:sanctum', 'abilities:check-status,place-orders']);


Route::get('/flights', function(){
    // Token has the "check-status" or "place-orders" ability...

    return response()->json([
        'success' => true,
        'data' => [
            'text' => 'Congrats! You have check-status or place-orders ability!'
        ]
    ]);
})->middleware(['auth:sanctum', 'ability:check-status,place-orders']);




// ----------------- SPA -----------------


Route::post('/authenticate', function(Request $request){
    $credentials = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    if (Auth::attempt($credentials)) {
        $request->session()->regenerate();

        return response()->json([
            'success' => true,
            'data' => [
                'text' => 'Congrats! Good job' 
            ],
            'errors' => []
        ], 200);
    }

    return response()->json([
        'success' => false,
        'data' => [
            'text' => 'You have an errors!' 
        ],
        'errors' => [
            'email' => 'The provided credentials do not match our records.',
        ]
    ], 401);
});