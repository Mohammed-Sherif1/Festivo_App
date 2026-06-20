import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { NotificationType } from "../notifications/types";
import { sendPushNotification } from "../notifications/send";

function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function addDays(date: Date, days: number): Date {
  const copy = new Date(date);
  copy.setDate(copy.getDate() + days);
  return copy;
}

function asString(value: unknown): string {
  return typeof value === "string" ? value : "";
}

export const sendBookingReminders = functions.pubsub
  .schedule("0 9 * * *")
  .timeZone("Africa/Cairo")
  .onRun(async () => {
    const db = admin.firestore();
    const tomorrow = startOfDay(addDays(new Date(), 1));
    const dayAfterTomorrow = startOfDay(addDays(new Date(), 2));

    const snap = await db
      .collection("bookings")
      .where("bookingStatus", "==", "Confirmed")
      .where("bookingDate", ">=", admin.firestore.Timestamp.fromDate(tomorrow))
      .where(
        "bookingDate",
        "<",
        admin.firestore.Timestamp.fromDate(dayAfterTomorrow),
      )
      .get();

    const tasks: Promise<void>[] = [];

    for (const doc of snap.docs) {
      const data = doc.data();
      if (data.reminderSent === true) continue;

      const userId = asString(data.userId);
      if (!userId) continue;

      const venueName = asString(data.venueName) || "your venue";
      const bookingTime = asString(data.bookingTime);
      const venueId = asString(data.venueId);
      const bookingId = doc.id;

      tasks.push(
        (async () => {
          await sendPushNotification({
            userId,
            title: "Booking Reminder",
            body: `Your event at ${venueName} is tomorrow${bookingTime ? ` at ${bookingTime}` : ""}.`,
            type: NotificationType.bookingReminder,
            data: { bookingId, venueId, targetRole: "customer" },
          });

          await doc.ref.update({ reminderSent: true });
        })(),
      );
    }

    await Promise.all(tasks);
    console.log(`Processed ${snap.size} booking reminder(s).`);
    return null;
  });
