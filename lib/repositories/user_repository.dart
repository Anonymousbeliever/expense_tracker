import '../models/user.dart';

/// Abstract repository interface for user data operations
abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserById(String id);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<void> saveUserProfile(User user);
}

/// Local implementation of user repository
/// This could be extended to include Firebase/API calls in the future
class LocalUserRepository implements UserRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User?> getUserById(String id) async {
    if (_currentUser?.id == id) {
      return _currentUser;
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    _currentUser = user;
  }

  @override
  Future<void> deleteUser(String id) async {
    if (_currentUser?.id == id) {
      _currentUser = null;
    }
  }

  @override
  Future<void> saveUserProfile(User user) async {
    _currentUser = user;
  }
}