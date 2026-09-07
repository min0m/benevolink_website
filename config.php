<?php
$hostname = "sql211.infinityfree.com"; 
$username = "if0_41871488";
$password = "jn7kd388gk0"; 
$database = "if0_41871488_benevolink"; 

// Create connection
$conn = new mysqli($hostname, $username, $password, $database, 3306);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Ensure character set is set properly for your data
$conn->set_charset("utf8mb4");
?>