import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/app/providers/app_providers.dart';
import 'package:festivo/core/constants/app_colors.dart';
import 'package:festivo/features/customer/domain/customer_models.dart';

class VenueReviewsScreen extends ConsumerWidget {
  final Venue venue;

  const VenueReviewsScreen({super.key, required this.venue});

  static void open(BuildContext context, Venue venue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VenueReviewsScreen(venue: venue)),
    );
  }

  static const _mockReviews = [
    (name: 'Sara M.', rating: 5.0, text: 'Absolutely stunning venue! Perfect for our wedding.', date: 'Mar 2026'),
    (name: 'Ahmed H.', rating: 4.5, text: 'Great staff and smooth booking process.', date: 'Feb 2026'),
    (name: 'Nour K.', rating: 4.0, text: 'Beautiful space, parking was a bit tight.', date: 'Jan 2026'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(isDarkProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(dark),
      appBar: AppBar(
        backgroundColor: AppColors.bg(dark),
        elevation: 0,
        title: Text('Reviews', style: TextStyle(color: AppColors.textD(dark))),
        iconTheme: IconThemeData(color: AppColors.textD(dark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card(dark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.shadow(dark)],
            ),
            child: Row(
              children: [
                Text(
                  venue.rating.toString(),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textD(dark),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < venue.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.gold,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${venue.reviews} reviews',
                        style: TextStyle(color: AppColors.textM(dark)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._mockReviews.map((r) => _ReviewCard(dark: dark, review: r)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final bool dark;
  final ({String name, double rating, String text, String date}) review;

  const _ReviewCard({required this.dark, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.shadow(dark)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent(dark).withOpacity(0.2),
                child: Text(
                  review.name[0],
                  style: TextStyle(
                    color: AppColors.accent(dark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textD(dark),
                      ),
                    ),
                    Text(
                      review.date,
                      style: TextStyle(fontSize: 12, color: AppColors.textL(dark)),
                    ),
                  ],
                ),
              ),
              Text(
                review.rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: TextStyle(color: AppColors.textM(dark), height: 1.5),
          ),
        ],
      ),
    );
  }
}
