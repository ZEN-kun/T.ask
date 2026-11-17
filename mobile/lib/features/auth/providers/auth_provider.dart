import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mobile/core/network/api_client.dart';
import 'package:task_mobile/features/auth/models/app_user.dart';
import 'package:task_mobile/services/api_service.dart';
import 'package:task_mobile/services/storage_service.dart';

// Core Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main()');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storageService: storage);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ApiService(client);
});

// Firebase Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Stream of ALL managers
final allManagersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .where('role', isEqualTo: 'manager')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();
  });
});

// Stream of managers filtered by company/organization name (case-insensitive in Dart)
final managersByOrganizationProvider = StreamProvider.family<List<AppUser>, String>((ref, organizationName) {
  final firestore = ref.watch(firestoreProvider);
  final target = organizationName.trim().toLowerCase();

  return firestore
      .collection('users')
      .where('role', isEqualTo: 'manager')
      .snapshots()
      .map((snapshot) {
    final all = snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();

    if (target.isEmpty) return [];

    // Filter by matching company name case-insensitively
    return all.where((m) {
      final comp = (m.companyName ?? '').trim().toLowerCase();
      return comp == target || comp.contains(target);
    }).toList();
  });
});

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._firestore) : super(AuthState(isLoading: true)) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        state = AuthState(isAuthenticated: false, isLoading: false);
      } else {
        await _loadUserProfile(user.uid);
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final appUser = AppUser.fromMap(doc.data()!, uid);
        state = state.copyWith(user: appUser, isAuthenticated: true, isLoading: false);
      } else {
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setUser(AppUser user) {
    state = state.copyWith(user: user);
  }

  Future<void> refreshProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _loadUserProfile(uid);
    }
  }

  // Register Manager
  Future<bool> registerManager({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String companyName,
    required String sector,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = creds.user!.uid;

      // Send Firebase Email Verification
      await creds.user?.sendEmailVerification();

      final manager = AppUser(
        uid: uid,
        email: email,
        name: name,
        phone: phone,
        role: 'manager',
        companyName: companyName,
        sector: sector,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(manager.toMap());
      state = state.copyWith(user: manager, isAuthenticated: true, isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _formatAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // Register Employee
  Future<bool> registerEmployee({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int age,
    required String companyName,
    required String department,
    required String managerId,
    required String managerName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = creds.user!.uid;

      // Send Firebase Email Verification
      await creds.user?.sendEmailVerification();

      final employee = AppUser(
        uid: uid,
        email: email,
        name: name,
        phone: phone,
        age: age,
        companyName: companyName,
        department: department,
        managerId: managerId,
        managerName: managerName,
        role: 'employee',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(employee.toMap());
      state = state.copyWith(user: employee, isAuthenticated: true, isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _formatAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserProfile(creds.user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _formatAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  String _formatAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }

  // Sign Out / Logout
  Future<void> logout() async {
    await _auth.signOut();
    state = AuthState(isAuthenticated: false);
  }

  Future<void> signOut() => logout();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthNotifier(auth, firestore);
});
