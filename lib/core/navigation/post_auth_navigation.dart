import 'package:flutter/material.dart';

import 'package:festivo/features/admin/screens/admin_dashboard_screen.dart';
import 'package:festivo/features/auth/screens/login_screen.dart';
import 'package:festivo/features/customer/screens/customer_shell.dart';
import 'package:festivo/features/owner/screens/owner_shell.dart';

/// Routes the user to the correct home screen after login or splash auth resolution.
void navigateForRole(BuildContext context, String role) {
  final normalized = role.toLowerCase().trim();
  final Widget destination;
  switch (normalized) {
    case 'admin':
      destination = const AdminDashboardScreen();
      break;
    case 'venue_owner':
      destination = const OwnerShell();
      break;
    default:
      destination = const CustomerShell();
      break;
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (route) => false,
  );
}

void navigateToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
