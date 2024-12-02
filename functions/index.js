const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
admin.initializeApp();

exports.cleanUpExpiredPosts = onSchedule("every 24 hours", async () => {
  const firestore = admin.firestore();
  const storage = admin.storage();
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

  for (const doc of expiredPostsSnapshot.docs) {
    const postData = doc.data();
    const mediaUrl = postData.mediaUrl;

    if (mediaUrl) {
      try {
        const filePath = decodeURIComponent(
            mediaUrl.split("/").slice(7).join("/"),
        );

        await storage.bucket().file(filePath).delete();
        console.log(`Deleted storage file: ${filePath}`);
      } catch (error) {
        console.error(`Failed to delete storage file: ${mediaUrl}`, error);
      }
    }

    batch.delete(doc.ref);
    console.log(`Scheduled for deletion: ${doc.id}`);
  }

  await batch.commit();
  console.log(
      "Expired posts and associated storage files deleted successfully.");
  return null;
});
