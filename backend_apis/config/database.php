<?php
/**
 * Database Configuration
 * 
 * This file contains the database connection configuration for the API endpoints.
 * Update the connection parameters according to your database setup.
 */

// Database configuration
$host = 'localhost';
$dbname = 'shyamtiles_db'; // Update with your actual database name
$username = 'your_username'; // Update with your actual username
$password = 'your_password'; // Update with your actual password
$charset = 'utf8mb4';

// PDO options
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    // Create PDO connection
    $dsn = "mysql:host=$host;dbname=$dbname;charset=$charset";
    $pdo = new PDO($dsn, $username, $password, $options);
    
    // Log successful connection (remove in production)
    error_log("Database connection established successfully");
    
} catch (PDOException $e) {
    // Log connection error
    error_log("Database connection failed: " . $e->getMessage());
    
    // Return error response
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Database connection failed'
    ]);
    exit();
}

// Database table structure reference:
// Based on the API response structure, it appears products are stored in the main tokens table
/*
CREATE TABLE IF NOT EXISTS tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    token_id VARCHAR(255) NOT NULL,
    vendor_name VARCHAR(255),
    customer_name VARCHAR(255),
    product_name VARCHAR(255) NOT NULL,
    size VARCHAR(100),
    quantity INT NOT NULL,
    date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    vendor_id VARCHAR(255),
    is_deleted TINYINT(1) DEFAULT 0,
    deleted_at TIMESTAMP NULL
);

-- Note: Each product in a token is stored as a separate row in the tokens table
-- Products are grouped by token_id when retrieved
*/
?>
