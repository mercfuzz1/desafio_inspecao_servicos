import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User?> restoreSession();

  Future<void> logout();

  Future<bool> hasSession();
}