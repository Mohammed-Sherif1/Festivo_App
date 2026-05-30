import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// User domain model — mirrors the Firestore 'users' document schema
// ─────────────────────────────────────────────
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'venue_owner' | 'admin'
  final bool isActive;
  final String? photoUrl;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    this.photoUrl,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  // ── Firestore → model ─────────────────────────────────────
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      isActive: data['isActive'] as bool? ?? true,
      photoUrl: data['photoUrl'] as String?,
      location: data['location'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── model → Firestore ─────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'isActive': isActive,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  // ── UI helpers ────────────────────────────────────────────

  /// First letter of the name, upper-cased; falls back to 'U'.
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  /// Human-readable role label shown in the UI.
  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'venue_owner':
        return 'Venue Owner';
      default:
        return 'Customer';
    }
  }

  /// Copy with changed fields.
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? photoUrl,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role,
        isActive: isActive ?? this.isActive,
        photoUrl: photoUrl ?? this.photoUrl,
        location: location ?? this.location,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        createdAt: createdAt,
      );
}
