export const NotificationType = {
  bookingSubmitted: "booking_submitted",
  bookingNewRequest: "booking_new_request",
  bookingApproved: "booking_approved",
  bookingRejected: "booking_rejected",
  bookingCancelled: "booking_cancelled",
  bookingReminder: "booking_reminder",
  reviewSubmitted: "review_submitted",
  venueApproved: "venue_approved",
  venueRejected: "venue_rejected",
  venueSubmitted: "venue_submitted",
} as const;

export type NotificationTypeValue =
  (typeof NotificationType)[keyof typeof NotificationType];

export interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  type: NotificationTypeValue;
  data?: Record<string, string>;
}
