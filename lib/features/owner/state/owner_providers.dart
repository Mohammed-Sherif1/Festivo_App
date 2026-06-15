import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/features/customer/domain/customer_booking.dart';
import 'package:festivo/features/customer/services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());

final ownerBookingsProvider = StreamProvider<List<CustomerBooking>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(bookingServiceProvider).watchOwnerBookings(uid);
});
