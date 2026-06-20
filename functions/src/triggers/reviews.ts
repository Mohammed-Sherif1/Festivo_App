import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { NotificationType } from "../notifications/types";
import { sendPushNotification } from "../notifications/send";

function asString(value: unknown): string {
  return typeof value === "string" ? value : "";
}

export const onReviewCreated = functions.firestore
  .document("reviews/{reviewId}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      const reviewId = context.params.reviewId as string;
      const venueId = asString(data.venueId);
      const venueName = asString(data.venueName) || "your venue";
      const userName = asString(data.userName) || "A customer";
      const rating = String(data.rating ?? "");

      if (!venueId) return;

      const venueDoc = await admin
        .firestore()
        .collection("venues")
        .doc(venueId)
        .get();
      if (!venueDoc.exists) {
        functions.logger.warn("Review venue not found", { venueId, reviewId });
        return;
      }

      const ownerId = asString(venueDoc.data()?.ownerId);
      if (!ownerId) return;

      functions.logger.info("Review created trigger", {
        reviewId,
        venueId,
        ownerId,
      });

      await sendPushNotification({
        userId: ownerId,
        title: "New Review Received",
        body: `${userName} left a ${rating}-star review on ${venueName}.`,
        type: NotificationType.reviewSubmitted,
        data: { reviewId, venueId, targetRole: "venue_owner" },
      });
    } catch (error) {
      functions.logger.error("onReviewCreated failed", { error });
      throw error;
    }
  });
