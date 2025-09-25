const functions = require("firebase-functions");
const express = require("express");
const axios = require("axios");
const admin = require("firebase-admin");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

const app = express();

// Enable CORS for all routes
app.use(cors({ origin: true }));
app.use(express.json());

// M-Pesa Daraja API Configuration
const MPESA_CONFIG = {
  // TODO: Replace with your actual credentials
  consumerKey: functions.config().mpesa?.consumer_key || "YOUR_CONSUMER_KEY",
  consumerSecret: functions.config().mpesa?.consumer_secret || "YOUR_CONSUMER_SECRET",
  shortcode: functions.config().mpesa?.shortcode || "174379", // Sandbox shortcode
  passkey: functions.config().mpesa?.passkey || "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919", // Sandbox passkey
  environment: functions.config().mpesa?.environment || "sandbox", // 'sandbox' or 'production'
};

// API URLs based on environment
const getBaseURL = (env) => {
  return env === "production" 
    ? "https://api.safaricom.co.ke" 
    : "https://sandbox.safaricom.co.ke";
};

// Check if running in emulator/demo mode
const isDemoMode = () => {
  return process.env.FUNCTIONS_EMULATOR === "true" || 
         MPESA_CONFIG.consumerKey === "YOUR_CONSUMER_KEY" ||
         !MPESA_CONFIG.consumerKey.startsWith("sU"); // Check if real key is set
};

// Generate M-Pesa access token
async function getAccessToken() {
  // Return mock token for demo mode
  if (isDemoMode()) {
    console.log("Demo mode: returning mock access token");
    return "mock_access_token_for_demo";
  }

  try {
    const auth = Buffer.from(
      `${MPESA_CONFIG.consumerKey}:${MPESA_CONFIG.consumerSecret}`
    ).toString("base64");
    
    const baseURL = getBaseURL(MPESA_CONFIG.environment);
    
    const response = await axios.get(
      `${baseURL}/oauth/v1/generate?grant_type=client_credentials`,
      {
        headers: { 
          Authorization: `Basic ${auth}`,
          "Content-Type": "application/json",
        },
      }
    );
    
    return response.data.access_token;
  } catch (error) {
    console.error("Error getting access token:", error.response?.data || error.message);
    throw new Error("Failed to get M-Pesa access token");
  }
}

// Generate password for STK Push
function generatePassword(shortcode, passkey, timestamp) {
  return Buffer.from(shortcode + passkey + timestamp).toString("base64");
}

// Format phone number to international format
function formatPhoneNumber(phoneNumber) {
  // Remove any spaces, dashes, or plus signs
  let cleaned = phoneNumber.replace(/[\s\-\+]/g, "");
  
  // If starts with 07, replace with 2547
  if (cleaned.startsWith("07")) {
    return "254" + cleaned.substring(1);
  }
  
  // If starts with 7, add 254
  if (cleaned.startsWith("7")) {
    return "254" + cleaned;
  }
  
  // If starts with 254, keep as is
  if (cleaned.startsWith("254")) {
    return cleaned;
  }
  
  // Default: assume it's a 7-digit number and add 254
  return "254" + cleaned;
}

// Validate request data
function validateSTKPushRequest(req) {
  const { phoneNumber, amount, userId } = req.body;
  const errors = [];

  if (!phoneNumber || phoneNumber.length < 9) {
    errors.push("Valid phone number is required");
  }

  if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
    errors.push("Valid amount is required (must be greater than 0)");
  }

  if (!userId || typeof userId !== "string") {
    errors.push("User ID is required");
  }

  return errors;
}

// STK Push endpoint
app.post("/stkpush", async (req, res) => {
  try {
    // Validate request
    const validationErrors = validateSTKPushRequest(req);
    if (validationErrors.length > 0) {
      return res.status(400).json({
        success: false,
        error: "Validation failed",
        details: validationErrors,
      });
    }

    const { phoneNumber, amount, userId } = req.body;
    const formattedPhone = formatPhoneNumber(phoneNumber);
    
    console.log(`STK Push request - User: ${userId}, Phone: ${formattedPhone}, Amount: ${amount}`);

    // Demo mode: Return mock success response
    if (isDemoMode()) {
      console.log("Demo mode: returning mock STK Push success");
      
      const transactionId = uuidv4();
      const mockCheckoutRequestId = `ws_CO_${Date.now()}`;
      const mockMerchantRequestId = `29115-34620561-1`;

      // Store mock transaction in Firestore for tracking
      try {
        await db.collection("transactions").doc(transactionId).set({
          userId: userId,
          phoneNumber: formattedPhone,
          amount: parseInt(amount),
          transactionType: "premium_upgrade",
          status: "pending",
          checkoutRequestId: mockCheckoutRequestId,
          merchantRequestId: mockMerchantRequestId,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      } catch (firestoreError) {
        console.log("Demo: Firestore not available in emulator, continuing...");
      }

      // Simulate STK Push success after 3 seconds (optional)
      setTimeout(async () => {
        try {
          await db.collection("transactions").doc(transactionId).update({
            status: "completed",
            resultCode: "0",
            resultDescription: "The service request is processed successfully.",
            mpesaReceiptNumber: `NLJ7RT61SV`,
            updatedAt: new Date(),
          });
          console.log(`Demo: Transaction ${transactionId} marked as completed`);
        } catch (err) {
          console.log("Demo: Firestore update not available in emulator");
        }
      }, 3000);

      return res.status(200).json({
        success: true,
        message: "STK Push initiated successfully (Demo Mode)",
        data: {
          checkoutRequestId: mockCheckoutRequestId,
          merchantRequestId: mockMerchantRequestId,
          responseDescription: "Success. Request accepted for processing",
          transactionId: transactionId,
        },
      });
    }

    // Get access token
    const token = await getAccessToken();

    // Generate timestamp
    const timestamp = new Date()
      .toISOString()
      .replace(/[^0-9]/g, "")
      .slice(0, 14);

    // Generate password
    const password = generatePassword(
      MPESA_CONFIG.shortcode,
      MPESA_CONFIG.passkey,
      timestamp
    );

    // Create transaction ID for tracking
    const transactionId = uuidv4();
    
    // Get callback URL
    const callbackURL = `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/api/callback`;

    // Prepare STK Push request
    const stkPushData = {
      BusinessShortCode: MPESA_CONFIG.shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: parseInt(amount),
      PartyA: formattedPhone,
      PartyB: MPESA_CONFIG.shortcode,
      PhoneNumber: formattedPhone,
      CallBackURL: callbackURL,
      AccountReference: `Premium-${userId}`,
      TransactionDesc: "Expense Tracker Premium Upgrade",
    };

    console.log("STK Push request data:", stkPushData);

    // Send STK Push request
    const baseURL = getBaseURL(MPESA_CONFIG.environment);
    const response = await axios.post(
      `${baseURL}/mpesa/stkpush/v1/processrequest`,
      stkPushData,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      }
    );

    console.log("STK Push response:", response.data);

    // Store transaction in Firestore for tracking
    await db.collection("transactions").doc(transactionId).set({
      userId: userId,
      phoneNumber: formattedPhone,
      amount: parseInt(amount),
      transactionType: "premium_upgrade",
      status: "pending",
      checkoutRequestId: response.data.CheckoutRequestID,
      merchantRequestId: response.data.MerchantRequestID,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Return success response
    res.status(200).json({
      success: true,
      message: "STK Push initiated successfully",
      data: {
        checkoutRequestId: response.data.CheckoutRequestID,
        merchantRequestId: response.data.MerchantRequestID,
        responseDescription: response.data.ResponseDescription,
        transactionId: transactionId,
      },
    });

  } catch (error) {
    console.error("STK Push error:", error.response?.data || error.message);
    
    res.status(500).json({
      success: false,
      error: "Failed to initiate STK Push",
      message: error.response?.data?.errorMessage || error.message,
    });
  }
});

// M-Pesa callback endpoint
app.post("/callback", async (req, res) => {
  const callbackData = req.body;
  console.log("M-Pesa Callback received:", JSON.stringify(callbackData, null, 2));

  try {
    const { Body } = callbackData;
    const { stkCallback } = Body;
    
    if (!stkCallback) {
      console.error("Invalid callback data structure");
      return res.status(400).json({ message: "Invalid callback data" });
    }

    const { 
      ResultCode, 
      ResultDesc, 
      CheckoutRequestID,
      MerchantRequestID 
    } = stkCallback;

    // Find transaction by CheckoutRequestID
    const transactionQuery = await db.collection("transactions")
      .where("checkoutRequestId", "==", CheckoutRequestID)
      .limit(1)
      .get();

    if (transactionQuery.empty) {
      console.error(`Transaction not found for CheckoutRequestID: ${CheckoutRequestID}`);
      return res.status(404).json({ message: "Transaction not found" });
    }

    const transactionDoc = transactionQuery.docs[0];
    const transactionData = transactionDoc.data();
    const transactionId = transactionDoc.id;
    const userId = transactionData.userId;

    console.log(`Processing callback for user: ${userId}, ResultCode: ${ResultCode}`);

    // Update transaction status
    const updateData = {
      resultCode: ResultCode,
      resultDescription: ResultDesc,
      merchantRequestId: MerchantRequestID,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (ResultCode === 0) {
      // Payment successful
      updateData.status = "completed";
      
      // Extract additional payment details if available
      if (stkCallback.CallbackMetadata && stkCallback.CallbackMetadata.Item) {
        const metadata = {};
        stkCallback.CallbackMetadata.Item.forEach(item => {
          metadata[item.Name] = item.Value;
        });
        updateData.paymentDetails = metadata;
        console.log("Payment metadata:", metadata);
      }

      // Update user to premium plan
      await db.collection("users").doc(userId).update({
        plan: "premium",
        planUpgradedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastPaymentTransactionId: transactionId,
      });

      console.log(`User ${userId} upgraded to premium successfully`);

    } else {
      // Payment failed or cancelled
      updateData.status = "failed";
      console.log(`Payment failed for user ${userId}: ${ResultDesc}`);
    }

    // Update transaction record
    await db.collection("transactions").doc(transactionId).update(updateData);

    res.status(200).json({ 
      message: "Callback processed successfully",
      resultCode: ResultCode 
    });

  } catch (error) {
    console.error("Callback processing error:", error);
    res.status(500).json({ 
      message: "Error processing callback",
      error: error.message 
    });
  }
});

// Transaction status check endpoint
app.get("/transaction/:transactionId", async (req, res) => {
  try {
    const { transactionId } = req.params;
    
    const transactionDoc = await db.collection("transactions").doc(transactionId).get();
    
    if (!transactionDoc.exists) {
      return res.status(404).json({
        success: false,
        error: "Transaction not found",
      });
    }

    const transactionData = transactionDoc.data();
    
    res.status(200).json({
      success: true,
      data: {
        transactionId: transactionDoc.id,
        status: transactionData.status,
        amount: transactionData.amount,
        resultCode: transactionData.resultCode,
        resultDescription: transactionData.resultDescription,
        createdAt: transactionData.createdAt,
        updatedAt: transactionData.updatedAt,
      },
    });

  } catch (error) {
    console.error("Error fetching transaction:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch transaction",
    });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "M-Pesa API is healthy",
    timestamp: new Date().toISOString(),
    environment: MPESA_CONFIG.environment,
  });
});

// Export the Express app as a Firebase Function
exports.api = functions.https.onRequest(app);