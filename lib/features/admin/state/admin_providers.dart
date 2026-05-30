import 'package:flutter_riverpod/legacy.dart';

import '../screens/admin_dashboard_screen.dart';

final adminTabProvider = StateProvider<AdminTab>((ref) => AdminTab.overview);

final adminUserSuspendedProvider = StateProvider.autoDispose.family<bool, int>(
  (ref, userIndex) => false,
);

final adminVenueStatusProvider = StateProvider.autoDispose
    .family<String, String>((ref, venueKey) => 'Pending');
