import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/app/providers/app_providers.dart';
import 'package:festivo/core/constants/app_colors.dart';

class CustomerBookingsScreen extends ConsumerWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(isDarkProvider);
    return Scaffold(
      backgroundColor: AppColors.bg(dark),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppColors.shadow(dark)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/logo.jpeg',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Center(child: Text('🎉', style: TextStyle(fontSize: 20))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Bookings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textD(dark),
                        ),
                      ),
                      Text(
                        'Manage your reservations',
                        style: TextStyle(fontSize: 14, color: AppColors.textM(dark)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _BookingCard(
                    venueName: 'Grand Crystal Ballroom',
                    eventType: 'Wedding',
                    location: 'Zamalek, Cairo',
                    date: 'Sun, Mar 15, 2026 • 6:00 PM',
                    status: 'Confirmed',
                    isConfirmed: true,
                    depositPaid: '7,500 EGP',
                    remainingAmount: '17,500 EGP',
                  ),
                  SizedBox(height: 16),
                  _BookingCard(
                    venueName: 'Sunset Rooftop Lounge',
                    eventType: 'Party',
                    location: 'Heliopolis, Cairo',
                    date: 'Fri, Apr 18, 2026 • 8:00 PM',
                    status: 'Pending',
                    isConfirmed: false,
                    remainingAmount: '12,000 EGP',
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final String venueName;
  final String eventType;
  final String location;
  final String date;
  final String status;
  final bool isConfirmed;
  final String? depositPaid;
  final String remainingAmount;

  const _BookingCard({
    required this.venueName,
    required this.eventType,
    required this.location,
    required this.date,
    required this.status,
    required this.isConfirmed,
    this.depositPaid,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(isDarkProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.shadow(dark)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  venueName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textD(dark),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isConfirmed
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF57F17),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softRose,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              eventType,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(location, style: TextStyle(color: AppColors.textM(dark))),
          const SizedBox(height: 10),
          Text(date, style: TextStyle(color: AppColors.textM(dark))),
          if (depositPaid != null) ...[
            const SizedBox(height: 6),
            Text('Deposit Paid: $depositPaid', style: const TextStyle(color: Color(0xFF2E7D32))),
          ],
          const SizedBox(height: 6),
          Text('Remaining: $remainingAmount', style: const TextStyle(color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }
}
