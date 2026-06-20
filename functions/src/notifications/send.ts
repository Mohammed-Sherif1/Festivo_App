import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";
import { NotificationPayload } from "./types";

const db = admin.firestore();
const messaging = admin.messaging();

function stringifyData(
  data?: Record<string, string>,
): Record<string, string> {
  const result: Record<string, string> = {};
  if (!data) return result;
  for (const [key, value] of Object.entries(data)) {
    result[key] = String(value ?? "");
  }
  return result;
}

async function getUserFcmToken(userId: string): Promise<string | null> {
  if (!userId) return null;
  const doc = await db.collection("users").doc(userId).get();
  if (!doc.exists) {
    functions.logger.warn("User document not found for push", { userId });
    return null;
  }
  const data = doc.data() ?? {};
  if (data.notificationsEnabled === false) {
    functions.logger.info("Push disabled for user", { userId });
    return null;
  }
  const token = data.fcmToken as string | undefined;
  if (!token || token.trim().length === 0) {
    functions.logger.warn("No FCM token stored for user", { userId });
    return null;
  }
  return token.trim();
}

async function saveInAppNotification(payload: NotificationPayload): Promise<void> {
  await db.collection("notifications").add({
    userId: payload.userId,
    title: payload.title,
    body: payload.body,
    type: payload.type,
    read: false,
    data: payload.data ?? {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

export async function sendPushNotification(
  payload: NotificationPayload,
): Promise<boolean> {
  const { userId, title, body, type, data } = payload;
  if (!userId) return false;

  try {
    await saveInAppNotification(payload);
  } catch (error) {
    functions.logger.error("Failed to save in-app notification", {
      userId,
      type,
      error,
    });
  }

  const token = await getUserFcmToken(userId);
  if (!token) {
    functions.logger.info("In-app notification saved without push delivery", {
      userId,
      type,
    });
    return false;
  }

  const stringData = stringifyData({
    ...data,
    type,
    click_action: "FLUTTER_NOTIFICATION_CLICK",
  });

  try {
    const messageId = await messaging.send({
      token,
      notification: { title, body },
      data: stringData,
      android: {
        priority: "high",
        notification: {
          channelId: "festivo_default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
          priority: "high",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            alert: { title, body },
            sound: "default",
            badge: 1,
            "content-available": 1,
          },
        },
      },
    });

    functions.logger.info("Push notification sent", {
      userId,
      type,
      messageId,
    });
    return true;
  } catch (error: unknown) {
    const code =
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      typeof (error as { code: unknown }).code === "string"
        ? (error as { code: string }).code
        : "";

    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      await db.collection("users").doc(userId).set(
        { fcmToken: admin.firestore.FieldValue.delete() },
        { merge: true },
      );
      functions.logger.warn("Removed invalid FCM token", { userId, code });
    }

    functions.logger.error("FCM send failed", { userId, type, code, error });
    return false;
  }
}

export async function sendToAdmins(
  title: string,
  body: string,
  type: NotificationPayload["type"],
  data?: Record<string, string>,
): Promise<void> {
  const admins = await db
    .collection("users")
    .where("role", "==", "admin")
    .get();

  if (admins.empty) {
    functions.logger.warn("No admin users found for notification", { type });
    return;
  }

  await Promise.all(
    admins.docs.map((doc) =>
      sendPushNotification({
        userId: doc.id,
        title,
        body,
        type,
        data,
      }),
    ),
  );
}

export async function sendToMany(
  userIds: string[],
  title: string,
  body: string,
  type: NotificationPayload["type"],
  data?: Record<string, string>,
): Promise<void> {
  const uniqueIds = [...new Set(userIds.filter(Boolean))];
  await Promise.all(
    uniqueIds.map((userId) =>
      sendPushNotification({ userId, title, body, type, data }),
    ),
  );
}
