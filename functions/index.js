const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendPushNotification = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") return res.status(204).send("");

    const { title, body } = req.body;

    if (!title || !body) {
      return res.status(400).json({ success: false, message: "Title and body required." });
    }

    try {
      const snapshot = await admin.firestore()
          .collection("user_fcm_tokens").get();

      if (snapshot.empty) {
        return res.json({ success: false, message: "No tokens" });
      }

      const tokens = [];
      snapshot.forEach(doc => {
        if (doc.data().token) tokens.push(doc.data().token);
      });

      console.log(`📱 Sending to ${tokens.length} devices`);

      const response = await admin.messaging().sendEachForMulticast({
        notification: { title, body },
        android: { notification: { sound: "default", priority: "high" } },
        tokens,
      });

      console.log(`✅ Success: ${response.successCount}/${tokens.length}`);
      return res.json({
        success: true,
        messageId: `sent_to_${response.successCount}_devices`
      });

    } catch (error) {
      console.error("❌ Error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }
  });