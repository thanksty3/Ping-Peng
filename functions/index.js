/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updateMessageStatus = functions.firestore
    .document("chatrooms/{chatRoomId}/messages/{messageId}")
    .onCreate((snap, context) => {
      const message = snap.data();
      if (message.status === "sent") {
        return snap.ref.update({status: "delivered"});
      }
      return null;
    });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
