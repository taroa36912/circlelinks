const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const Stripe = require("stripe");

admin.initializeApp();

const LINE_CHANNEL_ID = "2008357841"; 

function getStripeClient() {
  const secretKey =
    process.env.STRIPE_SECRET_KEY ||
    functions.config().stripe?.secret_key;

  if (!secretKey || secretKey === "YOUR_STRIPE_SECRET_KEY") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Stripe secret key is not configured."
    );
  }

  return Stripe(secretKey);
}

exports.verifyLineToken = functions.region('asia-northeast1').https.onCall(async (data, context) => {
  const idToken = data.idToken;

  if (!idToken) {
    throw new functions.https.HttpsError("invalid-argument", "The function must be called with an 'idToken'.");
  }

  try {
    const params = new URLSearchParams();
    params.append('id_token', idToken);
    params.append('client_id', LINE_CHANNEL_ID);

    const response = await axios.post("https://api.line.me/oauth2/v2.1/verify", params, {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      }
    });

    const lineProfile = response.data;

    const lineUserId = lineProfile.sub;
    
    const email = lineProfile.email || null;
    const displayName = lineProfile.name || "LINE User";
    const photoURL = lineProfile.picture || null;

    const uid = `line:${lineUserId}`;
    
    try {
      await admin.auth().getUser(uid);
      await admin.auth().updateUser(uid, {
        displayName: displayName,
        photoURL: photoURL,
      });
    } catch (e) {
      if (e.code === 'auth/user-not-found') {
        await admin.auth().createUser({
          uid: uid,
          displayName: displayName,
          email: email,
          photoURL: photoURL,
        });
      } else {
        throw e;
      }
    }

    const customToken = await admin.auth().createCustomToken(uid);
    return { customToken: customToken };

  } catch (error) {
    console.error("Error verifying LINE token:", error);
    throw new functions.https.HttpsError("internal", "Failed to verify LINE token.", error.message || String(error));
  }
});

exports.createStripePaymentIntent = functions.region('asia-northeast1').https.onCall(async (data, context) => {
  const amount = data?.amount;

  if (typeof amount !== 'number' || amount <= 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The function must be called with a positive numeric amount.'
    );
  }

  try {
    const stripe = getStripeClient();
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'jpy',
      payment_method_types: ['card'],
    });

    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error('Error creating Stripe PaymentIntent:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to create Stripe PaymentIntent.',
      error.message || String(error)
    );
  }
});
