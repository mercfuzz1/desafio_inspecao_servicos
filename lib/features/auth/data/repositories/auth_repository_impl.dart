import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    await secureStorage.saveAccessToken(
      response.accessToken,
    );

    return response.user;
  }

  @override
  Future<User?> restoreSession() async {
    final token = await secureStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await remoteDataSource.getMe();
    } catch (_) {
      await secureStorage.deleteAccessToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.deleteAccessToken();
  }

  @override
  Future<bool> hasSession() async {
    final token = await secureStorage.getAccessToken();

    return token != null && token.isNotEmpty;
  }
}