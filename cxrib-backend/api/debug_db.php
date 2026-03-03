<?php
header("Content-Type: application/json; charset=UTF-8");
require_once __DIR__ . "/db.php";

echo "<h2>Users</h2>";
$result = $conn->query("SELECT * FROM users");
while($row = $result->fetch_assoc()) { print_r($row); echo "<br>"; }

echo "<h2>Patients</h2>";
$result = $conn->query("SELECT * FROM patients");
while($row = $result->fetch_assoc()) { print_r($row); echo "<br>"; }

echo "<h2>Scan History</h2>";
$result = $conn->query("SELECT * FROM scan_history");
while($row = $result->fetch_assoc()) { print_r($row); echo "<br>"; }

echo "<h2>JOIN Test (First 10)</h2>";
$sql = "
SELECT
    sh.id,
    p.id AS patient_id,
    p.user_id,
    p.name
FROM scan_history sh
JOIN patients p ON p.id = sh.patient_id
LIMIT 10
";
$result = $conn->query($sql);
while($row = $result->fetch_assoc()) { print_r($row); echo "<br>"; }
?>
