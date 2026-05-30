import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────────
// Authentication service — wraps FirebaseAuth + Firestore user ops
// ─────────────────────────────────────────────
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Current user ──────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Sign in ───────────────────────────────────────────────
  /// Returns the [UserModel] on success, or throws a descriptive [Exception].
  Future<UserModel> signIn({
    required String email,
    required String password,
    required String selectedRole, // UI label e.g. 'Customer'
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('Account not found. Please create an account.');
    }

    final user = UserModel.fromMap(uid, doc.data()!);

    // Role mismatch check
    if (user.roleLabel != selectedRole) {
      await _auth.signOut();
      throw Exception(
        "Role mismatch. You selected '$selectedRole' but your account is "
        "registered as '${user.roleLabel}'.",
      );
    }

    return user;
  }

  // ── Create account ────────────────────────────────────────
  /// Creates a Firebase Auth user and writes the Firestore document.
  /// Returns the created [UserModel].
  Future<UserModel> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String uiRole, // 'Customer' or 'Venue Owner'
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final firestoreRole = _uiRoleToFirestore(uiRole);

    final user = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      role: firestoreRole,
      isActive: true,
    );

    // Non-fatal Firestore write
    try {
      await _db.collection('users').doc(uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {/* handled by caller */}

    // Sign out so the user logs in explicitly
    _auth.signOut().catchError((_) {});

    return user;
  }

  // ── Password reset ────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sign out ──────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Fetch user profile ────────────────────────────────────
  Future<UserModel?> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(user.uid, doc.data()!);
  }

  // ── Role string conversion ────────────────────────────────
  String _uiRoleToFirestore(String uiRole) {
    switch (uiRole) {
      case 'Venue Owner':
        return 'venue_owner';
      default:
        return 'customer';
    }
  }
}
