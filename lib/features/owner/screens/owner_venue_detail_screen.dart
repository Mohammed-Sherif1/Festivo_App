import 'package:flutter/material.dart';

import 'package:festivo/features/owner/domain/owner_models.dart';
import 'package:festivo/features/owner/theme/owner_colors.dart';
import 'package:festivo/features/owner/widgets/owner_widgets.dart';

class OwnerVenueDetailScreen extends StatelessWidget {
  final OwnerVenue venue;

  const OwnerVenueDetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(venue.name),
        backgroundColor: OwnerColors.pink,
        foregroundColor: Colors.white,
      ),
      backgroundColor: OwnerColors.pinkBg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OwnerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OwnerBadge.active(),
                const SizedBox(height: 12),
                _row('Category', venue.category),
                _row('Location', venue.location),
                _row('Price', '${venue.price.toStringAsFixed(0)} EGP'),
                _row('Capacity', '${venue.capacity} guests'),
                _row('Bookings', '${venue.bookingsCount}'),
                _row('Revenue', '${venue.revenue.toStringAsFixed(0)} EGP'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: OwnerColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: OwnerColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
