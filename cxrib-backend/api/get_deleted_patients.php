<?php
include "db.php";

$since = $_GET['since'] ?? '1970-01-01 00:00:00';

$sql = "
    SELECT id 
    FROM patients
    WHERE is_deleted = 1
    AND updated_at >= ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $since);
$stmt->execute();

$result = $stmt->get_result();

$deletedIds = [];
while ($row = $result->fetch_assoc()) {
    $deletedIds[] = (int)$row['id'];
}

echo json_encode([
    "deleted_ids" => $deletedIds
]);
