<?php

declare(strict_types=1);

use App\Support\ErrorHandler;
use Dotenv\Dotenv;

const BASE_PATH = __DIR__;

require BASE_PATH . '/vendor/autoload.php';

if (is_readable(BASE_PATH . '/.env')) {
    Dotenv::createImmutable(BASE_PATH)->safeLoad();
}

ErrorHandler::register();

return [
    'env' => $_ENV['APP_ENV'] ?? 'production',
    'debug' => filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOLEAN),
];
