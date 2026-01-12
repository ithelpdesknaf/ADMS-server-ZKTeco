<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class IClockAuthMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $username = $request->getUser();
        $password = $request->getPassword();

        if ($username !== env('ICLOCK_USERNAME') || $password !== env('ICLOCK_PASSWORD')) {
            return response('Unauthorized.', 401, ['WWW-Authenticate' => 'Basic']);
        }

        return $next($request);
    }
}
