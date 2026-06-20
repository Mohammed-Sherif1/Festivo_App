import * as functions from "firebase-functions/v1";
import { NotificationType } from "../notifications/types";
import { sendPushNotification } from "../notifications/send";

function asString(value: unknown): string {
  return typeof value === "string" ? value : "";
}

export const onBookingCreated = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      const bookingId = context.params.bookingId as string;
      const venueName = asString(data.venueName) || "your venue";
      const userId = asString(data.userId);
      const ownerId = asString(data.ownerId);
      const venueId = asString(data.venueId);

      functions.logger.info("Booking created trigger", {
        bookingId,
        userId,
        ownerId,
      });

      const tasks: Promise<boolean>[] = [];

      if (userId) {
        tasks.push(
          sendPushNotification({
            userId,
            title: "Booking Request Submitted",
            body: `Your booking request for ${venueName} was submitted successfully.`,
            type: NotificationType.bookingSubmitted,
            data: { bookingId, venueId, targetRole: "customer" },
          }),
        );
      }

      if (ownerId) {
        tasks.push(
          sendPushNotification({
            userId: ownerId,
            title: "New Booking Request",
            body: `You received a new booking request for ${venueName}.`,
            type: NotificationType.bookingNewRequest,
            data: { bookingId, venueId, targetRole: "venue_owner" },
          }),
        );
      }

      await Promise.all(tasks);
    } catch (error) {
      functions.logger.error("onBookingCreated failed", { error });
      throw error;
    }
  });

export const onBookingUpdated = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      const bookingId = context.params.bookingId as string;

      const prevStatus = asString(before.bookingStatus);
      const nextStatus = asString(after.bookingStatus);
      if (prevStatus === nextStatus) return;

      functions.logger.info("Booking updated trigger", {
        bookingId,
        prevStatus,
        nextStatus,
      });

      const venueName = asString(after.venueName) || "the venue";
      const userId = asString(after.userId);
      const ownerId = asString(after.ownerId);
      const venueId = asString(after.venueId);
      const cancelledBy = asString(after.cancelledBy);

      if (prevStatus === "Pending" && nextStatus === "Confirmed" && userId) {
        await sendPushNotification({
          userId,
          title: "Booking Approved",
          body: `Your booking at ${venueName} has been approved.`,
          type: NotificationType.bookingApproved,
          data: { bookingId, venueId, targetRole: "customer" },
        });
        return;
      }

      if (prevStatus === "Pending" && nextStatus === "Cancelled") {
        if (cancelledBy === "owner" && userId) {
          await sendPushNotification({
            userId,
            title: "Booking Rejected",
            body: `Your booking request for ${venueName} was declined.`,
            type: NotificationType.bookingRejected,
            data: { bookingId, venueId, targetRole: "customer" },
          });
          return;
        }

        if (cancelledBy === "customer" && ownerId) {
          await sendPushNotification({
            userId: ownerId,
            title: "Booking Cancelled",
            body: `A customer cancelled their booking for ${venueName}.`,
            type: NotificationType.bookingCancelled,
            data: { bookingId, venueId, targetRole: "venue_owner" },
          });
        }
      }
    } catch (error) {
      functions.logger.error("onBookingUpdated failed", { error });
      throw error;
    }
  });
