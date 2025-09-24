import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as AppUser;

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User? get currentFirebaseUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  // Convert Firebase User to App User
  AppUser.User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    return AppUser.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  // Auth state changes stream
  Stream<AppUser.User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      
      return AppUser.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      );
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Sign in with email and password
  Future<AppUser.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      _setLoading(false);
      notifyListeners();
      return currentUser!;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      _setLoading(false);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Create user with email and password
  Future<AppUser.User> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('Account creation failed - no user returned');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await result.user!.updateDisplayName(displayName);
        await result.user!.reload();
      }

      _setLoading(false);
      notifyListeners();
      return currentUser!;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      _setLoading(false);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      _setLoading(false);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _auth.signOut();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      throw Exception('Sign out failed: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    _setLoading(true);
    
    try {
      await _auth.currentUser?.delete();
      _setLoading(false);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      _setLoading(false);
      throw Exception('Account deletion failed: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    _setLoading(true);
    
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
      await _auth.currentUser?.reload();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      throw Exception('Profile update failed: $e');
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}