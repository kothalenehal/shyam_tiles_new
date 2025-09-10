<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'status' => 'error',
        'message' => 'Method not allowed. Only POST requests are accepted.'
    ]);
    exit();
}

// Include database configuration
require_once '../config/database.php';

try {
    // Get JSON input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    // Log the incoming request for debugging
    error_log("=== EDIT PRODUCT API REQUEST ===");
    error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
    error_log("Request Body: " . $input);
    error_log("Parsed Data: " . print_r($data, true));
    
    // Validate JSON input
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception('Invalid JSON format: ' . json_last_error_msg());
    }
    
    // Validate required fields
    if (!isset($data['token_id']) || empty($data['token_id'])) {
        throw new Exception('token_id is required');
    }
    
    if (!isset($data['old_product']) || !is_array($data['old_product'])) {
        throw new Exception('old_product is required and must be an object');
    }
    
    if (!isset($data['new_product']) || !is_array($data['new_product'])) {
        throw new Exception('new_product is required and must be an object');
    }
    
    // Validate old_product fields
    $oldProduct = $data['old_product'];
    if (!isset($oldProduct['product_name']) || empty($oldProduct['product_name'])) {
        throw new Exception('old_product.product_name is required');
    }
    if (!isset($oldProduct['size']) || empty($oldProduct['size'])) {
        throw new Exception('old_product.size is required');
    }
    if (!isset($oldProduct['quantity']) || !is_numeric($oldProduct['quantity'])) {
        throw new Exception('old_product.quantity is required and must be numeric');
    }
    
    // Validate new_product fields
    $newProduct = $data['new_product'];
    if (!isset($newProduct['product_name']) || empty($newProduct['product_name'])) {
        throw new Exception('new_product.product_name is required');
    }
    if (!isset($newProduct['size']) || empty($newProduct['size'])) {
        throw new Exception('new_product.size is required');
    }
    if (!isset($newProduct['quantity']) || !is_numeric($newProduct['quantity'])) {
        throw new Exception('new_product.quantity is required and must be numeric');
    }
    
    $tokenId = $data['token_id'];
    $oldProductName = $oldProduct['product_name'];
    $oldSize = $oldProduct['size'];
    $oldQuantity = (int)$oldProduct['quantity'];
    $newProductName = $newProduct['product_name'];
    $newSize = $newProduct['size'];
    $newQuantity = (int)$newProduct['quantity'];
    
    error_log("Processing edit request:");
    error_log("  Token ID: $tokenId");
    error_log("  Old Product: $oldProductName | $oldSize | Qty: $oldQuantity");
    error_log("  New Product: $newProductName | $newSize | Qty: $newQuantity");
    
    // Start database transaction
    $pdo->beginTransaction();
    
    try {
        // Based on the API response structure, it seems like the data is stored in a single table
        // Let's first check if the token exists and get its creation time
        $tokenQuery = "SELECT created_at FROM tokens WHERE token_id = ? AND is_deleted = 0 LIMIT 1";
        $tokenStmt = $pdo->prepare($tokenQuery);
        $tokenStmt->execute([$tokenId]);
        $tokenData = $tokenStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$tokenData) {
            throw new Exception('Token not found or has been deleted');
        }
        
        $tokenCreatedAt = $tokenData['created_at'];
        error_log("Token found - Created: $tokenCreatedAt");
        
        // Check if token is within 30-minute edit window
        $currentTime = new DateTime();
        $tokenCreatedTime = new DateTime($tokenCreatedAt);
        $timeDifference = $currentTime->getTimestamp() - $tokenCreatedTime->getTimestamp();
        $thirtyMinutes = 30 * 60; // 30 minutes in seconds
        
        if ($timeDifference > $thirtyMinutes) {
            throw new Exception('Token edit window has expired. Products can only be edited within 30 minutes of token creation.');
        }
        
        error_log("Token is within edit window. Time difference: " . ($timeDifference / 60) . " minutes");
        
        // Based on the API response, it looks like products are stored in the main tokens table
        // Let's get all products for this token to see what we're working with
        $debugQuery = "SELECT id, product_name, size, quantity FROM tokens 
                      WHERE token_id = ? AND is_deleted = 0";
        $debugStmt = $pdo->prepare($debugQuery);
        $debugStmt->execute([$tokenId]);
        $allProducts = $debugStmt->fetchAll(PDO::FETCH_ASSOC);
        
        error_log("All products for token $tokenId:");
        foreach ($allProducts as $product) {
            error_log("  Product ID: {$product['id']}, Name: {$product['product_name']}, Size: {$product['size']}, Qty: {$product['quantity']}");
        }
        
        // Find ALL products that match the exact criteria (for quantity updates, we want to update all duplicates)
        $findProductQuery = "SELECT id FROM tokens 
                           WHERE token_id = ? 
                           AND product_name = ? 
                           AND size = ? 
                           AND quantity = ? 
                           AND is_deleted = 0";
        $findProductStmt = $pdo->prepare($findProductQuery);
        $findProductStmt->execute([$tokenId, $oldProductName, $oldSize, $oldQuantity]);
        $productData = $findProductStmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (empty($productData)) {
            error_log("Product not found with exact match:");
            error_log("  Looking for: Name='$oldProductName', Size='$oldSize', Qty='$oldQuantity'");
            error_log("  Available products:");
            foreach ($allProducts as $product) {
                error_log("    Name='{$product['product_name']}', Size='{$product['size']}', Qty='{$product['quantity']}'");
            }
            throw new Exception('Product not found with the specified details. Please ensure the old product details match exactly.');
        }
        
        $productIds = array_column($productData, 'id');
        error_log("Found " . count($productIds) . " products to update - IDs: " . implode(', ', $productIds));
        
        // Check if the new product details are the same as old (no change needed)
        if ($oldProductName === $newProductName && $oldSize === $newSize && $oldQuantity == $newQuantity) {
            error_log("No changes detected - product details are identical");
            throw new Exception('No changes detected. The new product details are identical to the old ones.');
        }
        
        // Update ALL matching products with new details
        $placeholders = str_repeat('?,', count($productIds) - 1) . '?';
        $updateProductQuery = "UPDATE tokens 
                             SET product_name = ?, size = ?, quantity = ?, updated_at = NOW() 
                             WHERE id IN ($placeholders)";
        $updateParams = array_merge([$newProductName, $newSize, $newQuantity], $productIds);
        $updateProductStmt = $pdo->prepare($updateProductQuery);
        $updateResult = $updateProductStmt->execute($updateParams);
        
        if (!$updateResult) {
            throw new Exception('Failed to update products');
        }
        
        $updatedCount = $updateProductStmt->rowCount();
        error_log("Updated $updatedCount products successfully - IDs: " . implode(', ', $productIds));
        error_log("  From: Name='$oldProductName', Size='$oldSize', Qty='$oldQuantity'");
        error_log("  To: Name='$newProductName', Size='$newSize', Qty='$newQuantity'");
        
        // Get count of remaining products for this token
        $countQuery = "SELECT COUNT(*) as product_count FROM tokens 
                      WHERE token_id = ? AND is_deleted = 0";
        $countStmt = $pdo->prepare($countQuery);
        $countStmt->execute([$tokenId]);
        $countResult = $countStmt->fetch(PDO::FETCH_ASSOC);
        $remainingProducts = $countResult['product_count'];
        
        // Commit transaction
        $pdo->commit();
        
        error_log("Transaction committed successfully");
        
        // Return success response
        $response = [
            'status' => 'success',
            'message' => "Product edited successfully. Updated $updatedCount products.",
            'updated_products' => [
                'count' => $updatedCount,
                'ids' => $productIds,
                'product_name' => $newProductName,
                'size' => $newSize,
                'quantity' => $newQuantity
            ],
            'remaining_products' => $remainingProducts,
            'edit_window_remaining' => max(0, $thirtyMinutes - $timeDifference)
        ];
        
        error_log("=== EDIT PRODUCT API SUCCESS ===");
        error_log("Response: " . json_encode($response));
        
        echo json_encode($response);
        
    } catch (Exception $e) {
        // Rollback transaction on error
        $pdo->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    error_log("=== EDIT PRODUCT API ERROR ===");
    error_log("Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
} catch (Error $e) {
    error_log("=== EDIT PRODUCT API FATAL ERROR ===");
    error_log("Fatal Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Internal server error'
    ]);
}
?>
