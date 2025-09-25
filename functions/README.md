# M-Pesa Firebase Functions Setup

This directory contains Firebase Cloud Functions for M-Pesa STK Push integration.

## Setup Instructions

### 1. Install Dependencies
```bash
cd functions
npm install
```

### 2. Configure M-Pesa Credentials
Set your M-Pesa credentials using Firebase configuration:

```bash
# Replace with your actual credentials
firebase functions:config:set mpesa.consumer_key="YOUR_CONSUMER_KEY"
firebase functions:config:set mpesa.consumer_secret="YOUR_CONSUMER_SECRET"
firebase functions:config:set mpesa.shortcode="YOUR_SHORTCODE"
firebase functions:config:set mpesa.passkey="YOUR_PASSKEY"
firebase functions:config:set mpesa.environment="sandbox"  # or "production"
```

### 3. Deploy Functions
```bash
firebase deploy --only functions
```

## API Endpoints

### STK Push
- **URL**: `https://us-central1-YOUR_PROJECT.cloudfunctions.net/api/stkpush`
- **Method**: POST
- **Body**:
```json
{
  "phoneNumber": "0712345678",
  "amount": "5.00",
  "userId": "user_id_here"
}
```

### Callback (Automatic)
- **URL**: `https://us-central1-YOUR_PROJECT.cloudfunctions.net/api/callback`
- **Method**: POST
- **Called automatically by M-Pesa**

### Transaction Status
- **URL**: `https://us-central1-YOUR_PROJECT.cloudfunctions.net/api/transaction/{transactionId}`
- **Method**: GET

### Health Check
- **URL**: `https://us-central1-YOUR_PROJECT.cloudfunctions.net/api/health`
- **Method**: GET

## Testing

Use the sandbox environment for testing:
- Consumer Key: Get from Daraja Portal
- Consumer Secret: Get from Daraja Portal
- Shortcode: 174379 (sandbox)
- Passkey: bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919 (sandbox)

## Security Notes

- Credentials are stored in Firebase Functions config
- All transactions are logged in Firestore
- Phone numbers are validated and formatted
- User authentication should be implemented in the client app