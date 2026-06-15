import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../models/stat_model.dart';
import '../models/activity_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/activity_card.dart';
import 'package:festivo/features/customer/state/venue_providers.dart';
import '../widgets/venue_card.dart';
import '../state/admin_providers.dart';

// ─────────────────────────────────────────────
// Admin tab enum
// ─────────────────────────────────────────────
enum AdminTab { overview, users, venues }

// ─────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────
const _stats = [
  StatModel(
    label: 'Total Users',
    value: '3',
    icon: Icons.group,
    iconColor: AppColors.borderBlue,
    borderColor: AppColors.borderBlue,
  ),
  StatModel(
    label: 'Venues',
    value: '3',
    icon: Icons.account_balance,
    iconColor: AppColors.borderGreen,
    borderColor: AppColors.borderGreen,
  ),
  StatModel(
    label: 'Pending',
    value: '2',
    icon: Icons.hourglass_top_rounded,
    iconColor: AppColors.borderOrange,
    borderColor: AppColors.borderOrange,
  ),
  StatModel(
    label: 'Bookings',
    value: '20',
    icon: Icons.calendar_month_rounded,
    iconColor: AppColors.borderGold,
    borderColor: AppColors.borderGold,
  ),
];

const _activities = [
  ActivityModel(
    title: 'New venue approved',
    subtitle: 'Grand Crystal Ballroom · 2 hours ago',
    icon: Icons.check_rounded,
    iconColor: AppColors.borderGreen,
    iconBg: AppColors.actGreenBg,
  ),
  ActivityModel(
    title: 'New user registered',
    subtitle: 'Omar Ali · 5 hours ago',
    icon: Icons.person_outline_rounded,
    iconColor: AppColors.borderBlue,
    iconBg: AppColors.actBlueBg,
  ),
  ActivityModel(
    title: 'Venue pending verification',
    subtitle: 'Sunset Rooftop · 1 day ago',
    icon: Icons.timer_outlined,
    iconColor: AppColors.borderGold,
    iconBg: AppColors.actYellowBg,
  ),
];

// ─────────────────────────────────────────────
// Admin Dashboard Screen
// ─────────────────────────────────────────────
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(adminTabProvider);
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _AdminHeader(onLogOut: () => _handleLogOut(context)),
            _AdminTabBar(
              activeTab: activeTab,
              onTabChanged: (t) {
                ref.read(adminTabProvider.notifier).state = t;
              },
            ),
            Expanded(
              child: activeTab == AdminTab.overview
                  ? const _OverviewTab()
                  : activeTab == AdminTab.users
                      ? const _UsersTab()
                      : const _VenuesTab(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.softRose),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  final VoidCallback onLogOut;
  const _AdminHeader({required this.onLogOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.softRose, AppColors.deepRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Platform management',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _LogOutButton(onPressed: onLogOut),
        ],
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogOutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 15, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab Bar
// ─────────────────────────────────────────────
class _AdminTabBar extends StatelessWidget {
  final AdminTab activeTab;
  final ValueChanged<AdminTab> onTabChanged;

  const _AdminTabBar({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _TabItem(
            label: 'Overview',
            isActive: activeTab == AdminTab.overview,
            onTap: () => onTabChanged(AdminTab.overview),
          ),
          _TabItem(
            label: 'Users',
            isActive: activeTab == AdminTab.users,
            onTap: () => onTabChanged(AdminTab.users),
          ),
          _TabItem(
            label: 'Venues',
            isActive: activeTab == AdminTab.venues,
            onTap: () => onTabChanged(AdminTab.venues),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.softRose
                      : AppColors.textLight,
                ),
              ),
            ),
            Container(
              height: 2.5,
              color:
                  isActive ? AppColors.softRose : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Overview Tab
// ─────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatsGrid(),
          const SizedBox(height: 14),
          const _RevenueCard(),
          const SizedBox(height: 22),
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ..._activities.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ActivityCard(item: a),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, i) => StatCard(data: _stats[i]),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.softRose, AppColors.deepRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.softRose.withOpacity(0.30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Revenue',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '444,000 EGP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '↑ +12% this month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'EGP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Users Tab
// ─────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  static const _users = [
    {'name': 'Ahmed Hassan', 'email': 'contact@festivo.app', 'role': 'Customer', 'status': 'Active'},
    {'name': 'Sara Mohamed', 'email': 'contact@festivo.app', 'role': 'Owner', 'status': 'Active'},
    {'name': 'Omar Ali', 'email': 'contact@festivo.app', 'role': 'Customer', 'status': 'Active'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final u = _users[i];
        final isOwner = u['role'] == 'Owner';
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isOwner
                    ? AppColors.gold.withOpacity(0.18)
                    : AppColors.softRose.withOpacity(0.25),
                child: Text(
                  u['name']![0],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isOwner ? AppColors.gold : AppColors.deepRose,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u['email']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _SmallBadge(
                          label: u['role']!,
                          bg: isOwner
                              ? AppColors.gold.withOpacity(0.15)
                              : AppColors.softRose.withOpacity(0.18),
                          color: isOwner ? AppColors.gold : AppColors.deepRose,
                        ),
                        const SizedBox(width: 6),
                        const _SmallBadge(
                          label: 'Active',
                          bg: AppColors.actGreenBg,
                          color: Color(0xFF15803D),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _SuspendButton(userIndex: i),
            ],
          ),
        );
      },
    );
  }
}

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

class _SuspendButton extends ConsumerStatefulWidget {
  final int userIndex;
  const _SuspendButton({required this.userIndex});

  @override
  ConsumerState<_SuspendButton> createState() => _SuspendButtonState();
}

class _SuspendButtonState extends ConsumerState<_SuspendButton> {
  @override
  Widget build(BuildContext context) {
    final suspended = ref.watch(adminUserSuspendedProvider(widget.userIndex));
    return GestureDetector(
      onTap: () {
        ref.read(adminUserSuspendedProvider(widget.userIndex).notifier).state =
            !suspended;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(
            color: suspended
                ? AppColors.borderGreen
                : AppColors.softRose,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          suspended ? 'Unsuspend' : 'Suspend',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: suspended
                ? AppColors.borderGreen
                : AppColors.softRose,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Venues Tab
// ─────────────────────────────────────────────
class _VenuesTab extends ConsumerWidget {
  const _VenuesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(adminVenuesProvider);

    return venuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Could not load venues')),
      data: (venues) {
        if (venues.isEmpty) {
          return const Center(child: Text('No venues submitted yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: venues.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => VenueCard(venue: venues[i]),
        );
      },
    );
  }
}
