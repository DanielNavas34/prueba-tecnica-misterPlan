<?php

declare(strict_types=1);

namespace App\Support;

use Throwable;

final class ErrorHandler
{
    public static function register(): void
    {
        set_exception_handler([self::class, 'handleException']);
        set_error_handler([self::class, 'handleError']);
    }

    public static function handleError(int $severity, string $message, string $file, int $line): bool
    {
        if (!(error_reporting() & $severity)) {
            return false;
        }

        throw new \ErrorException($message, 0, $severity, $file, $line);
    }

    public static function handleException(Throwable $throwable): void
    {
        self::log($throwable);

        if (!headers_sent()) {
            http_response_code(500);
            header('Content-Type: application/json; charset=utf-8');
        }

        $debug = filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOLEAN);

        if ($debug) {
            echo json_encode([
                'error' => [
                    'code' => 'INTERNAL_ERROR',
                    'message' => $throwable->getMessage(),
                ],
            ], JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'error' => [
                    'code' => 'INTERNAL_ERROR',
                    'message' => 'Ha ocurrido un error interno.',
                ],
            ], JSON_UNESCAPED_UNICODE);
        }
    }

    private static function log(Throwable $throwable): void
    {
        $logDir = BASE_PATH . '/var/log';
        if (!is_dir($logDir)) {
            return;
        }

        $line = sprintf(
            "[%s] %s in %s:%d\n",
            date('c'),
            $throwable->getMessage(),
            $throwable->getFile(),
            $throwable->getLine(),
        );

        @file_put_contents($logDir . '/app.log', $line, FILE_APPEND | LOCK_EX);
    }
}
