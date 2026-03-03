<?php
require_once __DIR__ . "/db.php";

// Check if column exists
$checkQuery = "SHOW COLUMNS FROM scan_history LIKE 'is_deleted'";
$result = $conn->query($checkQuery);

if ($result && $result->num_rows > 0) {
    echo "Column 'is_deleted' already exists in 'scan_history'.\n";
} else {
    // Add column
    $sql = "ALTER TABLE scan_history ADD COLUMN is_deleted TINYINT(1) DEFAULT 0";
    if ($conn->query($sql) === TRUE) {
        echo "Successfully added 'is_deleted' column to 'scan_history'.\n";
    } else {
        echo "Error adding column: " . $conn->error . "\n";
    }
}
?>
