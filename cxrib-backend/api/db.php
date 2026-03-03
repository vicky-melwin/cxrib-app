<?php
// =====================================================
// ERROR REPORTING (DEV MODE)
// =====================================================
error_reporting(E_ALL);
ini_set('display_errors', 1);

// =====================================================
// CORS HEADERS
// =====================================================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// =====================================================
// DATABASE CONFIG  ✅ TCP/IP ONLY (NO SOCKET)
// =====================================================
$host = "127.0.0.1";   // 🔥 NOT localhost
$user = "root";
$pass = "";        // removed password as requested
$db   = "cerviscan_db";
$port = 3306;

// =====================================================
// MYSQL CONNECTION
// =====================================================
$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "DB connection failed",
        "error" => $conn->connect_error
    ]);
    exit;
}

$conn->set_charset("utf8mb4");
