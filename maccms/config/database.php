<?php
return [
    'type' => 'mysql',
    'hostname' => getenv('DB_HOST') ?: 'localhost',
    'database' => getenv('DB_NAME') ?: 'quicktv',
    'username' => getenv('DB_USER') ?: 'root',
    'password' => getenv('DB_PASS') ?: '',
    'hostport' => getenv('DB_PORT') ?: '3306',
    'charset' => 'utf8mb4',
    'prefix' => 'mac_',
    'debug' => true,
];
