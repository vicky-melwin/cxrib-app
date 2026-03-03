<?php
// test_soft_delete.php
require_once __DIR__ . "/db.php";

echo "--- 1. Creating Test Data ---\n";
// Create user, patient, scan
$user_id = 9999; // Mock user
$conn->query("INSERT IGNORE INTO users (id, name, email, password) VALUES ($user_id, 'TestUser', 'test@example.com', 'pass')");
$conn->query("INSERT INTO patients (user_id, name, age, gender, case_id) VALUES ($user_id, 'TestPatient', 30, 'Male', 101)");
$patient_id = $conn->insert_id;
$conn->query("INSERT INTO scan_history (patient_id, label, confidence, image_url) VALUES ($patient_id, 'Normal', 0.99, 'http://test.com/img.jpg')");
$scan_id = $conn->insert_id;

echo "Created Patient ID: $patient_id, Scan ID: $scan_id\n";

echo "\n--- 2. Calling delete_scan.php ---\n";
// Simulate POST request
$_POST['scan_id'] = $scan_id;
ob_start();
include "delete_scan.php";
$output = ob_get_clean();
echo "Delete API Output: $output\n";

echo "\n--- 3. Verifying Database State ---\n";
$res = $conn->query("SELECT id, is_deleted FROM scan_history WHERE id = $scan_id");
$row = $res->fetch_assoc();
echo "Scan ID $scan_id is_deleted: " . ($row['is_deleted'] ?? 'NULL') . "\n";

if ($row['is_deleted'] == 1) {
    echo "✅ Success: Scan marked as deleted.\n";
} else {
    echo "❌ Failure: Scan NOT marked as deleted.\n";
}

echo "\n--- 4. Verifying get_scan_history.php Results ---\n";
$_GET['user_id'] = $user_id;
ob_start();
include "get_scan_history.php";
$history_json = ob_get_clean();
$history = json_decode($history_json, true);

$found = false;
foreach ($history['scans'] as $scan) {
    if ($scan['id'] == $scan_id) {
        $found = true;
        break;
    }
}

if (!$found) {
    echo "✅ Success: Deleted scan not found in history list.\n";
} else {
    echo "❌ Failure: Deleted scan STILL found in history list.\n";
}

// Cleanup
$conn->query("DELETE FROM scan_history WHERE id = $scan_id");
$conn->query("DELETE FROM patients WHERE id = $patient_id");
$conn->query("DELETE FROM users WHERE id = $user_id");
?>
