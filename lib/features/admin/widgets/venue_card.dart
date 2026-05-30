import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../state/admin_providers.dart';

// ─────────────────────────────────────────────
// Venue Manage Card used in the admin Venues tab
// ─────────────────────────────────────────────
class VenueCard extends ConsumerStatefulWidget {
  final Map<String, String> venue;

  const VenueCard({super.key, required this.venue});

  @override
  ConsumerState<VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends ConsumerState<VenueCard> {
  late final String _key;

  @override
  void initState() {
    super.initState();
    _key = widget.venue['name'] ?? widget.venue.toString();
    ref.read(adminVenueStatusProvider(_key).notifier).state =
        widget.venue['status'] ?? 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;
    final status = ref.watch(adminVenueStatusProvider(_key));
    final isPending = status == 'Pending';
    final isApproved = status == 'Approved';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.softRose.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  venue['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _SmallBadge(
                label: venue['cat']!,
                bg: AppColors.softRose.withOpacity(0.18),
                color: AppColors.deepRose,
              ),
              const SizedBox(width: 6),
              _SmallBadge(
                label: status,
                bg: isApproved
                    ? AppColors.actGreenBg
                    : isPending
                        ? const Color(0xFFFEF9C3)
                        : const Color(0xFFFEE2E2),
                color: isApproved
                    ? const Color(0xFF15803D)
                    : isPending
                        ? const Color(0xFFCA8A04)
                        : const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Owner: ${venue['owner']!}',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          // Action buttons (only when pending)
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: '✓ Approve',
                    bg: const Color(0xFF22C55E),
                    onTap: () {
                      ref.read(adminVenueStatusProvider(_key).notifier).state =
                          'Approved';
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: '✗ Reject',
                    bg: const Color(0xFFEF4444),
                    onTap: () {
                      ref.read(adminVenueStatusProvider(_key).notifier).state =
                          'Rejected';
                    },
                  ),
                ),
              ],
            ),
          ],
          if (!isPending)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                isApproved ? 'No action required' : 'Venue rejected',
                style: TextStyle(
                  fontSize: 12,
                  color: isApproved
                      ? AppColors.textLight
                      : const Color(0xFFEF4444),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Small Badge ───────────────────────────────────────────────
class _SmallBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color color;

  const _SmallBadge({
    required this.label,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final Color bg;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
