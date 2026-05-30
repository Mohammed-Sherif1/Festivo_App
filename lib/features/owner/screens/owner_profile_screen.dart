import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:festivo/core/navigation/post_auth_navigation.dart';
import 'package:festivo/features/owner/theme/owner_colors.dart';
import 'package:festivo/features/owner/widgets/owner_widgets.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  String _name = 'Venue Owner';
  String _email = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (!mounted) return;
      setState(() {
        _name = (data?['name'] as String?)?.trim().isNotEmpty == true
            ? data!['name'] as String
            : 'Venue Owner';
        _email = (data?['email'] as String?) ?? user.email ?? '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: OwnerColors.pinkBg,
        body: Center(child: CircularProgressIndicator(color: OwnerColors.pink)),
      );
    }

    return Scaffold(
      backgroundColor: OwnerColors.pinkBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: OwnerColors.grad),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : 'V',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: OwnerColors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Venue Owner',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OwnerCard(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline, color: OwnerColors.pink),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Contact Festivo support'),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                OwnerCard(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: OwnerColors.red),
                    title: const Text('Log Out', style: TextStyle(color: OwnerColors.red)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      navigateToLogin(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
