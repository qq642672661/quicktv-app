<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../api/Database.php';
require_once __DIR__ . '/../api/Router.php';
require_once __DIR__ . '/../api/Response.php';

$config = require __DIR__ . '/../config/database.php';
$db = new Database($config);

$router = new Router($db);

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/maccms/public', '', $path);

try {
    $router->dispatch($method, $path);
} catch (Exception $e) {
    Response::error($e->getMessage(), 500);
}
