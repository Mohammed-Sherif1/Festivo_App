import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:festivo/app/providers/app_providers.dart';
import 'package:festivo/core/constants/app_colors.dart';

class ProfileSubPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;

  const ProfileSubPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final dark = ref.watch(isDarkProvider);
        return Scaffold(
          backgroundColor: AppColors.profileBg(dark),
          appBar: AppBar(
            backgroundColor: AppColors.profileBg(dark),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.profileTextD(dark), fontSize: 18)),
                Text(subtitle, style: TextStyle(color: AppColors.profileTextM(dark), fontSize: 12)),
              ],
            ),
            iconTheme: IconThemeData(color: AppColors.profileTextD(dark)),
          ),
          body: body,
        );
      },
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _bookingConf = true;
  bool _paymentRem = true;
  bool _newVenues = false;
  bool _promotions = false;

  static const _recent = [
    _Notif(
      icon: Icons.check_circle_rounded,
      iconBg: Color(0xFFD4F0DF),
      iconColor: Color(0xFF4CAF50),
      title: 'Booking Confirmed',
      subtitle: 'Grand Crystal Ballroom — Mar 15, 2026',
      time: '2 hours ago',
      unread: true,
    ),
    _Notif(
      icon: Icons.credit_card_rounded,
      iconBg: Color(0xFFFFF3CD),
      iconColor: Color(0xFFE8A87C),
      title: 'Payment Due',
      subtitle: 'Sunset Rooftop — 3,000 EGP remaining',
      time: '1 day ago',
      unread: true,
    ),
    _Notif(
      icon: Icons.business_rounded,
      iconBg: Color(0xFFDDE8FF),
      iconColor: Color(0xFF7B9FD4),
      title: 'New Venue Available',
      subtitle: 'Nile View Hall added in Maadi',
      time: '3 days ago',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileSubPage(
      title: 'Notifications',
      subtitle: 'Manage your alerts',
      body: Consumer(
        builder: (context, ref, _) {
          final dark = ref.watch(isDarkProvider);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('PREFERENCES', dark),
                const SizedBox(height: 10),
                _card(
                  dark,
                  child: Column(
                    children: [
                      _toggle('Booking Confirmations', _bookingConf, (v) => setState(() => _bookingConf = v), dark),
                      _divider(dark),
                      _toggle('Payment Reminders', _paymentRem, (v) => setState(() => _paymentRem = v), dark),
                      _divider(dark),
                      _toggle('New Venues', _newVenues, (v) => setState(() => _newVenues = v), dark),
                      _divider(dark),
                      _toggle('Promotions & Offers', _promotions, (v) => setState(() => _promotions = v), dark),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionLabel('RECENT', dark),
                const SizedBox(height: 10),
                ..._recent.map((n) => _notifCard(n, dark)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text, bool dark) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.profileTextM(dark),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _card(bool dark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.profileCard(dark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.shadow(dark)],
      ),
      child: child,
    );
  }

  Widget _divider(bool dark) => Divider(height: 1, indent: 16, color: AppColors.profileBorder(dark));

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppColors.profileTextD(dark), fontSize: 15))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent(dark),
          ),
        ],
      ),
    );
  }

  Widget _notifCard(_Notif n, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.profileCard(dark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.shadow(dark)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: n.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(n.icon, color: n.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: TextStyle(color: AppColors.profileTextD(dark), fontWeight: FontWeight.w600)),
                Text(n.subtitle, style: TextStyle(color: AppColors.profileTextM(dark), fontSize: 12)),
                Text(n.time, style: TextStyle(color: AppColors.profileTextM(dark), fontSize: 11)),
              ],
            ),
          ),
          if (n.unread) const CircleAvatar(radius: 5, backgroundColor: Color(0xFFE8A87C)),
        ],
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;

  const _Notif({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
  });
}

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  int _selected = 0;

  static const _methods = [
    _PayMethod(Icons.payments_rounded, Color(0xFFD4F0DF), Color(0xFF4CAF50), 'Cash', 'Pay on arrival at the venue'),
    _PayMethod(Icons.dialpad_rounded, Color(0xFFDDE0FF), Color(0xFF7B9FD4), 'Vodafone Cash', 'Pay via Vodafone Cash wallet'),
    _PayMethod(Icons.bolt_rounded, Color(0xFFFFF3CD), Color(0xFFE8A87C), 'InstaPay', 'Instant bank transfer via InstaPay'),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileSubPage(
      title: 'Payment Methods',
      subtitle: 'Choose your preferred method',
      body: Consumer(
        builder: (context, ref, _) {
          final dark = ref.watch(isDarkProvider);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...List.generate(_methods.length, (i) {
                final m = _methods[i];
                final sel = _selected == i;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.profileCard(dark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? AppColors.accent(dark) : AppColors.profileBorder(dark),
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: m.iconBg, borderRadius: BorderRadius.circular(12)),
                          child: Icon(m.icon, color: m.iconColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.profileTextD(dark))),
                              Text(m.subtitle, style: TextStyle(fontSize: 12, color: AppColors.profileTextM(dark))),
                            ],
                          ),
                        ),
                        Icon(
                          sel ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: sel ? AppColors.accent(dark) : AppColors.profileTextM(dark),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _PayMethod {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _PayMethod(this.icon, this.iconBg, this.iconColor, this.title, this.subtitle);
}

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSubPage(
      title: 'Privacy & Security',
      subtitle: 'Account controls',
      body: Consumer(
        builder: (context, ref, _) {
          final dark = ref.watch(isDarkProvider);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tile(dark, Icons.lock_outline, 'Change Password', 'Update your login password'),
              _tile(dark, Icons.fingerprint, 'Biometric Login', 'Use fingerprint or face ID'),
              _tile(dark, Icons.visibility_off_outlined, 'Profile Visibility', 'Control who sees your profile'),
              _tile(dark, Icons.delete_outline, 'Delete Account', 'Permanently remove your account', danger: true),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(bool dark, IconData icon, String title, String subtitle, {bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.profileCard(dark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.shadow(dark)],
      ),
      child: ListTile(
        leading: Icon(icon, color: danger ? Colors.red : AppColors.accent(dark)),
        title: Text(title, style: TextStyle(color: danger ? Colors.red : AppColors.profileTextD(dark))),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.profileTextM(dark), fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: AppColors.profileTextM(dark)),
        onTap: () {},
      ),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(isDarkProvider);
    return ProfileSubPage(
      title: 'Settings',
      subtitle: 'App preferences',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.profileCard(dark),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [AppColors.shadow(dark)],
            ),
            child: SwitchListTile(
              title: Text('Dark Mode', style: TextStyle(color: AppColors.profileTextD(dark))),
              subtitle: Text('Switch to dark color theme', style: TextStyle(color: AppColors.profileTextM(dark))),
              value: dark,
              activeColor: AppColors.accent(dark),
              onChanged: (v) => ref.read(isDarkProvider.notifier).state = v,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.profileCard(dark),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text('Language', style: TextStyle(color: AppColors.profileTextD(dark))),
              subtitle: Text('English', style: TextStyle(color: AppColors.profileTextM(dark))),
              trailing: Icon(Icons.chevron_right, color: AppColors.profileTextM(dark)),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalDocPage extends StatelessWidget {
  final String title;
  final String body;

  const LegalDocPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return ProfileSubPage(
      title: title,
      subtitle: 'Legal information',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(body, style: const TextStyle(height: 1.6)),
      ),
    );
  }
}
