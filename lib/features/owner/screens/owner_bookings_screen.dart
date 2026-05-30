import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/features/owner/domain/owner_models.dart';
import 'package:festivo/features/owner/state/owner_store.dart';
import 'package:festivo/features/owner/theme/owner_colors.dart';
import 'package:festivo/features/owner/widgets/owner_widgets.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(ownerStoreProvider).bookings;

    return Scaffold(
      backgroundColor: OwnerColors.pinkBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: OwnerColors.grad),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
            child: const Text(
              'Bookings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final b = bookings[i];
                return OwnerCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.venueName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: OwnerColors.textDark,
                              ),
                            ),
                          ),
                          _statusBadge(b.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(b.customerName, style: const TextStyle(color: OwnerColors.textMid)),
                      Text('${b.date} · ${b.timeSlot}', style: const TextStyle(fontSize: 12, color: OwnerColors.textGrey)),
                      const SizedBox(height: 8),
                      Text(
                        '${b.amount.toStringAsFixed(0)} EGP · ${b.guests} guests',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: OwnerColors.gold),
                      ),
                      if (b.status == BookingStatus.pending) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => ref
                                    .read(ownerStoreProvider.notifier)
                                    .updateBookingStatus(b.id, BookingStatus.cancelled),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OwnerColors.pink,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => ref
                                    .read(ownerStoreProvider.notifier)
                                    .updateBookingStatus(b.id, BookingStatus.confirmed),
                                child: const Text('Confirm'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return OwnerBadge.confirmed();
      case BookingStatus.pending:
        return OwnerBadge.pending();
      case BookingStatus.completed:
        return OwnerBadge.completed();
      case BookingStatus.cancelled:
        return OwnerBadge.cancelled();
    }
  }
}
