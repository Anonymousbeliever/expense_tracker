import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // Dummy user database (in real app, this would be on server)
  final Map<String, String> _users = {
    'test@example.com': 'password123',
    'user@demo.com': 'demo123',
    'admin@test.com': 'admin123',
  };

  // Stream to notify listeners of auth state changes
  Stream<User?> get authStateChanges {
    return Stream.periodic(const Duration(milliseconds: 100), (_) => _currentUser)
        .distinct();
  }

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (!_users.containsKey(email)) {
      _setLoading(false);
      throw AuthException('No user found with this email address.');
    }

    if (_users[email] != password) {
      _setLoading(false);
      throw AuthException('Wrong password provided for that user.');
    }

    _currentUser = User(
      id: email.hashCode.toString(),
      email: email,
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _setLoading(false);
    notifyListeners();
    return _currentUser!;
  }

  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (_users.containsKey(email)) {
      _setLoading(false);
      throw AuthException('The account already exists for that email.');
    }

    // Add user to dummy database
    _users[email] = password;

    _currentUser = User(
      id: email.hashCode.toString(),
      email: email,
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _setLoading(false);
    notifyListeners();
    return _currentUser!;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (!_users.containsKey(email)) {
      _setLoading(false);
      throw AuthException('No user found with this email address.');
    }

    _setLoading(false);
    // In a real app, this would send an actual email
    // For now, we'll just simulate success
  }

  Future<void> updateDisplayName(String displayName) async {
    if (_currentUser == null) {
      throw AuthException('No user is currently signed in.');
    }

    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Update the current user's display name
    _currentUser = _currentUser!.copyWith(displayName: displayName.trim());
    
    _setLoading(false);
    notifyListeners();
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize with a pre-signed user for testing (optional)
  void initializeWithTestUser() {
    _currentUser = User(
      id: 'test123',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
    notifyListeners();
  }
}