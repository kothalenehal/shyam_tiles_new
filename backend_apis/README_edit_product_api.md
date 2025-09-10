# Edit Product API Endpoint

## Overview
This API endpoint allows editing individual products within an existing token while maintaining the 30-minute edit window validation.

## Endpoint Details
- **Method**: POST
- **URL**: `/apis/token/edit-product`
- **Content-Type**: application/json

## Request Payload
```json
{
    "token_id": "TOKEN_1757447842_6475",
    "old_product": {
        "product_name": "Product A",
        "size": "Large",
        "quantity": 2
    },
    "new_product": {
        "product_name": "Updated Product A",
        "size": "Extra Large",
        "quantity": 5
    }
}
```

## Request Parameters

### Required Fields
- `token_id` (string): The unique identifier of the token
- `old_product` (object): The current product details to be replaced
  - `product_name` (string): Current product name
  - `size` (string): Current product size
  - `quantity` (number): Current product quantity
- `new_product` (object): The new product details
  - `product_name` (string): New product name
  - `size` (string): New product size
  - `quantity` (number): New product quantity

## Response Format

### Success Response (200 OK)
```json
{
    "status": "success",
    "message": "Product edited successfully",
    "updated_product": {
        "id": 123,
        "product_name": "Updated Product A",
        "size": "Extra Large",
        "quantity": 5
    },
    "remaining_products": 3,
    "edit_window_remaining": 1200
}
```

### Error Response (400 Bad Request)
```json
{
    "status": "error",
    "message": "Token edit window has expired. Products can only be edited within 30 minutes of token creation."
}
```

## Validation Rules

1. **Token Validation**:
   - Token must exist in the database
   - Token must not be deleted (`is_deleted = 0`)

2. **Time Window Validation**:
   - Token must be within 30 minutes of creation
   - Edit window is calculated from `created_at` timestamp

3. **Product Validation**:
   - Old product must exist with exact matching details
   - All product fields (name, size, quantity) must be provided
   - Quantity must be numeric

4. **Data Validation**:
   - All required fields must be present
   - JSON format must be valid
   - Product names and sizes cannot be empty

## Error Cases

### 1. Invalid JSON Format
```json
{
    "status": "error",
    "message": "Invalid JSON format: Syntax error"
}
```

### 2. Missing Required Fields
```json
{
    "status": "error",
    "message": "token_id is required"
}
```

### 3. Token Not Found
```json
{
    "status": "error",
    "message": "Token not found or has been deleted"
}
```

### 4. Edit Window Expired
```json
{
    "status": "error",
    "message": "Token edit window has expired. Products can only be edited within 30 minutes of token creation."
}
```

### 5. Product Not Found
```json
{
    "status": "error",
    "message": "Product not found with the specified details"
}
```

### 6. Database Error
```json
{
    "status": "error",
    "message": "Failed to update product"
}
```

## Database Schema

### Tables Used
1. **tokens**: Main token information
2. **token_products**: Individual products within tokens

### Key Fields
- `tokens.token_id`: Unique token identifier
- `tokens.created_at`: Token creation timestamp
- `tokens.is_deleted`: Soft delete flag
- `token_products.product_name`: Product name
- `token_products.size`: Product size
- `token_products.quantity`: Product quantity
- `token_products.is_deleted`: Soft delete flag

## Security Features

1. **SQL Injection Protection**: Uses prepared statements
2. **Input Validation**: Comprehensive field validation
3. **Transaction Safety**: Database transactions with rollback
4. **Error Logging**: Detailed error logging for debugging
5. **CORS Support**: Proper CORS headers for web requests

## Logging

The API provides comprehensive logging for debugging:
- Request details (method, body, parsed data)
- Token validation results
- Time window calculations
- Product matching results
- Database operation results
- Error details with stack traces

## Usage Examples

### cURL Example
```bash
curl -X POST https://your-domain.com/apis/token/edit-product \
  -H "Content-Type: application/json" \
  -d '{
    "token_id": "TOKEN_1757447842_6475",
    "old_product": {
        "product_name": "Armani marble grey",
        "size": "2x4",
        "quantity": 12
    },
    "new_product": {
        "product_name": "Armani marble grey (Premium)",
        "size": "2x4",
        "quantity": 15
    }
  }'
```

### JavaScript Example
```javascript
const response = await fetch('/apis/token/edit-product', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify({
        token_id: 'TOKEN_1757447842_6475',
        old_product: {
            product_name: 'Armani marble grey',
            size: '2x4',
            quantity: 12
        },
        new_product: {
            product_name: 'Armani marble grey (Premium)',
            size: '2x4',
            quantity: 15
        }
    })
});

const result = await response.json();
console.log(result);
```

## Integration with Flutter App

The Flutter app includes:
- `editProductInToken()` function for API calls
- `testEditProductAPI()` function for testing
- `_editProductWithAPI()` helper for UI integration
- Comprehensive error handling and user feedback
- Loading indicators and success/error messages

## Testing

Use the test function in the Flutter app:
```dart
await testEditProductAPI();
```

This will:
1. Find the first available token with products
2. Edit the first product with modified values
3. Display detailed logging of the operation
4. Refresh the token list to show changes

## Deployment Notes

1. Update database configuration in `config/database.php`
2. Ensure proper file permissions
3. Configure web server to handle PHP requests
4. Set up proper error logging
5. Test with actual database data
6. Monitor API performance and error rates
