<?php

declare(strict_types=1);

namespace App\Support;

final class HttpSecurityHeaders
{
    public static function sendDefaults(): void
    {
        if (headers_sent()) {
            return;
        }

        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('Referrer-Policy: strict-origin-when-cross-origin');
    }
}
