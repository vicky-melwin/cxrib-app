<?php
require_once __DIR__ . "/db.php";

$scan_id = intval($_POST['scan_id'] ?? 0);
if ($scan_id <= 0) {
    echo json_encode(["status" => "error"]);
    exit;
}

/* 1️⃣ Find patient_id for this scan */
$stmt = $conn->prepare(
    "SELECT patient_id FROM scan_history WHERE id = ?"
);
$stmt->bind_param("i", $scan_id);
$stmt->execute();
$res = $stmt->get_result();

if (!$row = $res->fetch_assoc()) {
    echo json_encode(["status" => "not_found"]);
    exit;
}

$patient_id = (int)$row['patient_id'];
$stmt->close();

/* 2️⃣ Soft Delete scan */
$stmt = $conn->prepare(
    "UPDATE scan_history SET is_deleted = 1 WHERE id = ?"
);
$stmt->bind_param("i", $scan_id);
if (!$stmt->execute()) {
    echo json_encode(["status" => "error", "message" => "Failed to delete scan"]);
    exit;
}
$stmt->close();

/* 3️⃣ Check remaining visible scans */
$stmt = $conn->prepare(
    "SELECT COUNT(*) AS cnt FROM scan_history WHERE patient_id = ? AND is_deleted = 0"
);
$stmt->bind_param("i", $patient_id);
$stmt->execute();
$countRes = $stmt->get_result();
$countRow = $countRes->fetch_assoc();
$stmt->close();

/* 4️⃣ Soft Delete patient ONLY if no visible scans left */
if ((int)$countRow['cnt'] === 0) {
    $stmt = $conn->prepare(
        "UPDATE patients SET is_deleted = 1 WHERE id = ?"
    );
    $stmt->bind_param("i", $patient_id);
    $stmt->execute();
    $stmt->close();
}

echo json_encode(["status" => "success"]);
