enum BookingStatus { pending, confirmed, completed, cancelled }

class OwnerVenue {
  final int id;
  final String name;
  final String location;
  final String category;
  final double price;
  final int capacity;
  final bool isActive;
  final int bookingsCount;
  final double revenue;

  const OwnerVenue({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.price,
    required this.capacity,
    this.isActive = true,
    this.bookingsCount = 0,
    this.revenue = 0,
  });

  OwnerVenue copyWith({
    String? name,
    String? location,
    String? category,
    double? price,
    int? capacity,
    bool? isActive,
    int? bookingsCount,
    double? revenue,
  }) {
    return OwnerVenue(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      category: category ?? this.category,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      revenue: revenue ?? this.revenue,
    );
  }
}

class OwnerBooking {
  final int id;
  final String venueName;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String date;
  final String timeSlot;
  final int guests;
  final double amount;
  final double depositPaid;
  final BookingStatus status;

  const OwnerBooking({
    required this.id,
    required this.venueName,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.date,
    required this.timeSlot,
    required this.guests,
    required this.amount,
    required this.depositPaid,
    required this.status,
  });
}
