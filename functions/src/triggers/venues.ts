import * as functions from "firebase-functions/v1";
import { NotificationType } from "../notifications/types";
import { sendPushNotification, sendToAdmins } from "../notifications/send";

function asString(value: unknown): string {
  return typeof value === "string" ? value : "";
}

export const onVenueCreated = functions.firestore
  .document("venues/{venueId}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      const venueId = context.params.venueId as string;
      const venueName = asString(data.name) || "New venue";
      const ownerName = asString(data.ownerName) || "A venue owner";

      functions.logger.info("Venue created trigger", { venueId, venueName });

      await sendToAdmins(
        "New Venue Pending Approval",
        `${ownerName} submitted "${venueName}" for review.`,
        NotificationType.venueSubmitted,
        { venueId, targetRole: "admin" },
      );
    } catch (error) {
      functions.logger.error("onVenueCreated failed", { error });
      throw error;
    }
  });

export const onVenueUpdated = functions.firestore
  .document("venues/{venueId}")
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      const venueId = context.params.venueId as string;

      const prevStatus = asString(before.status);
      const nextStatus = asString(after.status);
      if (prevStatus === nextStatus) return;
      if (nextStatus !== "Approved" && nextStatus !== "Rejected") return;

      const ownerId = asString(after.ownerId);
      if (!ownerId) return;

      const venueName = asString(after.name) || "your venue";
      const approved = nextStatus === "Approved";

      functions.logger.info("Venue status changed trigger", {
        venueId,
        nextStatus,
        ownerId,
      });

      await sendPushNotification({
        userId: ownerId,
        title: approved ? "Venue Approved" : "Venue Rejected",
        body: approved
          ? `"${venueName}" is now live on Festivo.`
          : `"${venueName}" was not approved. Please review and resubmit.`,
        type: approved
          ? NotificationType.venueApproved
          : NotificationType.venueRejected,
        data: { venueId, targetRole: "venue_owner" },
      });
    } catch (error) {
      functions.logger.error("onVenueUpdated failed", { error });
      throw error;
    }
  });
