# Complete M-Pesa Integration Setup Guide

## Phase 1: Firebase Cloud Functions Setup

### 1. Initialize Firebase Functions (if not already done)
```bash
cd expense_tracker
firebase init functions
```

Choose:
- JavaScript (not TypeScript)
- Install dependencies with npm

### 2. Install Dependencies
```bash
cd functions
npm install
```

### 3. Configure M-Pesa Credentials
You need to get these from Safaricom Daraja Portal (https://developer.safaricom.co.ke/):

**For Sandbox Testing:**
```bash
firebase functions:config:set mpesa.consumer_key="YOUR_SANDBOX_CONSUMER_KEY"
firebase functions:config:set mpesa.consumer_secret="YOUR_SANDBOX_CONSUMER_SECRET"
firebase functions:config:set mpesa.shortcode="174379"
firebase functions:config:set mpesa.passkey="bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
firebase functions:config:set mpesa.environment="sandbox"
```

**For Production:**
```bash
firebase functions:config:set mpesa.consumer_key="YOUR_PRODUCTION_CONSUMER_KEY"
firebase functions:config:set mpesa.consumer_secret="YOUR_PRODUCTION_CONSUMER_SECRET"
firebase functions:config:set mpesa.shortcode="YOUR_PRODUCTION_SHORTCODE"
firebase functions:config:set mpesa.passkey="YOUR_PRODUCTION_PASSKEY"
firebase functions:config:set mpesa.environment="production"
```

### 4. Deploy Functions
```bash
firebase deploy --only functions
```

### 5. Test the API
After deployment, your endpoints will be available at:
- STK Push: `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api/stkpush`
- Callback: `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api/callback`
- Health: `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api/health`

## Phase 2: Flutter App Configuration

### 1. Update Project ID
In `lib/services/mpesa_service.dart`, replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

### 2. Install HTTP Package
```bash
flutter pub get
```

### 3. Update User Model (if needed)
Ensure your user model includes a `plan` field to track premium status:

```dart
// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String displayName;
  final String plan; // 'free' or 'premium'
  final DateTime? planUpgradedAt;
  // ... other fields
}
```

### 4. Update Firestore Security Rules
Add rules to allow users to read their own plan status:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions are read-only for users, write-only for functions
    match /transactions/{transactionId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Expenses rules (existing)
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

## Phase 3: Testing

### 1. Sandbox Testing
Use these test numbers for sandbox:
- **Test Phone**: 254708374149 (or any valid Kenyan number)
- **Test Amount**: Any amount (e.g., 5.00 for premium)

### 2. Testing Flow
1. Open the app
2. Navigate to In-App Purchase
3. Select premium plan
4. Enter phone number (254708374149 for sandbox)
5. Tap "Pay Securely"
6. You should see STK push notification
7. Enter PIN: **1234** (sandbox PIN)
8. Check app for success/failure status

### 3. Monitoring
Monitor the process using:
- Firebase Functions logs: `firebase functions:log`
- Firestore console for transaction records
- App debug logs for status updates

## Phase 4: Production Deployment

### 1. Get Production Credentials
1. Complete Safaricom Go-Live process
2. Get production consumer key, secret, shortcode, and passkey
3. Update Firebase config with production credentials

### 2. Update Environment
```bash
firebase functions:config:set mpesa.environment="production"
firebase deploy --only functions
```

### 3. Update App Configuration
- Change project ID in MpesaService
- Build and deploy production app

## Security Considerations

1. **Never expose credentials** in client code
2. **Use Firebase Functions config** for sensitive data
3. **Implement user authentication** before payment
4. **Validate all inputs** on both client and server
5. **Monitor transactions** for suspicious activity
6. **Set up proper error handling** and logging

## Troubleshooting

### Common Issues:
1. **"Invalid credentials"**: Check consumer key/secret
2. **"Invalid shortcode"**: Verify shortcode matches environment
3. **"Callback not received"**: Check callback URL format
4. **"User not found"**: Ensure user is authenticated
5. **"Function timeout"**: Check function timeout settings

### Debug Tips:
- Check Firebase Functions logs
- Verify Firestore security rules
- Test with sandbox first
- Monitor M-Pesa developer portal

## Support

- Safaricom Developer Portal: https://developer.safaricom.co.ke/
- Firebase Functions Documentation: https://firebase.google.com/docs/functions
- M-Pesa API Documentation: https://developer.safaricom.co.ke/docs