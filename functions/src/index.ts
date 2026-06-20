import * as admin from "firebase-admin";

admin.initializeApp();

export { onBookingCreated, onBookingUpdated } from "./triggers/bookings";
export { onVenueCreated, onVenueUpdated } from "./triggers/venues";
export { onReviewCreated } from "./triggers/reviews";
export { sendBookingReminders } from "./scheduled/bookingReminders";
