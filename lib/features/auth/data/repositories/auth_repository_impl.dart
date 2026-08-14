import '../datasources/auth_remote_data_source.dart';
import '../../models/auth_response_model.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(
      email: email,
      password: password,
    );
  }
}