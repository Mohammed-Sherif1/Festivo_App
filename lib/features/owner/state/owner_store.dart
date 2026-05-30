import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/features/owner/domain/owner_models.dart';

class OwnerStoreState {
  final List<OwnerVenue> venues;
  final List<OwnerBooking> bookings;

  const OwnerStoreState({
    required this.venues,
    required this.bookings,
  });

  factory OwnerStoreState.initial() => OwnerStoreState(
        venues: List.of(_initialVenues),
        bookings: List.of(_initialBookings),
      );

  int get totalBookings => venues.fold(0, (s, v) => s + v.bookingsCount);
  double get totalRevenue => venues.fold(0.0, (s, v) => s + v.revenue);
  int get activeCount => venues.where((v) => v.isActive).length;
}

class OwnerStore extends Notifier<OwnerStoreState> {
  @override
  OwnerStoreState build() => OwnerStoreState.initial();

  void deleteVenue(int id) {
    state = OwnerStoreState(
      venues: state.venues.where((v) => v.id != id).toList(),
      bookings: state.bookings,
    );
  }

  void addVenue(OwnerVenue venue) {
    state = OwnerStoreState(
      venues: [...state.venues, venue],
      bookings: state.bookings,
    );
  }

  void updateVenue(OwnerVenue venue) {
    state = OwnerStoreState(
      venues: [
        for (final v in state.venues) if (v.id == venue.id) venue else v,
      ],
      bookings: state.bookings,
    );
  }

  void updateBookingStatus(int id, BookingStatus status) {
    state = OwnerStoreState(
      venues: state.venues,
      bookings: [
        for (final b in state.bookings)
          if (b.id == id)
            OwnerBooking(
              id: b.id,
              venueName: b.venueName,
              customerName: b.customerName,
              customerPhone: b.customerPhone,
              customerEmail: b.customerEmail,
              date: b.date,
              timeSlot: b.timeSlot,
              guests: b.guests,
              amount: b.amount,
              depositPaid: b.depositPaid,
              status: status,
            )
          else
            b,
      ],
    );
  }
}

final ownerStoreProvider =
    NotifierProvider<OwnerStore, OwnerStoreState>(OwnerStore.new);

const _initialVenues = [
  OwnerVenue(
    id: 1,
    name: 'Grand Crystal Ballroom',
    location: 'New Cairo',
    category: 'Wedding',
    price: 25000,
    capacity: 300,
    bookingsCount: 12,
    revenue: 180000,
  ),
  OwnerVenue(
    id: 2,
    name: 'Royal Garden Plaza',
    location: 'Maadi',
    category: 'Wedding',
    price: 18000,
    capacity: 250,
    bookingsCount: 8,
    revenue: 95000,
  ),
];

const _initialBookings = [
  OwnerBooking(
    id: 1,
    venueName: 'Grand Crystal Ballroom',
    customerName: 'Ahmed Hassan',
    customerPhone: '+20 100 234 5678',
    customerEmail: 'ahmed@email.com',
    date: 'Sat, Mar 15, 2026',
    timeSlot: '6:00 PM – 11:00 PM',
    guests: 150,
    amount: 25000,
    depositPaid: 5000,
    status: BookingStatus.confirmed,
  ),
  OwnerBooking(
    id: 2,
    venueName: 'Royal Garden Plaza',
    customerName: 'Sara Mohamed',
    customerPhone: '+20 111 345 6789',
    customerEmail: 'sara.m@email.com',
    date: 'Fri, Apr 18, 2026',
    timeSlot: '3:00 PM – 6:00 PM',
    guests: 80,
    amount: 18000,
    depositPaid: 0,
    status: BookingStatus.pending,
  ),
];
