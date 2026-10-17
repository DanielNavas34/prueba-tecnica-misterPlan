<?php

declare(strict_types=1);

use App\Support\Database;
use App\Support\HttpSecurityHeaders;

$config = require dirname(__DIR__) . '/bootstrap.php';

HttpSecurityHeaders::sendDefaults();
header('Content-Type: application/json; charset=utf-8');

echo json_encode([
    'service' => 'web',
    'status' => 'ok',
    'environment' => $config['env'],
    'database' => Database::ping() ? 'connected' : 'unavailable',
], JSON_UNESCAPED_UNICODE);
