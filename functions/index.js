/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
admin.initializeApp();

exports.cleanUpExpiredPosts = onSchedule("every 24 hours", async () => {
  const firestore = admin.firestore();
  const now = admin.firestore.Timestamp.now();
  const expirationTime =
    new Date(now.toMillis() - 24 * 60 * 60 * 1000); // 24 hours ago

  const postsRef = firestore.collection("posts");
  const expiredPostsSnapshot = await postsRef
      .where("timestamp", "<", expirationTime).get();

  if (expiredPostsSnapshot.empty) {
    console.log("No expired posts found.");
    return null;
  }

  const batch = firestore.batch();
  expiredPostsSnapshot.forEach((doc) => {
    batch.delete(doc.ref);
    console.log(`Scheduled for deletion: ${doc.id}`);
  });

  await batch.commit();
  console.log("Expired posts deleted successfully.");
  return null;
});
