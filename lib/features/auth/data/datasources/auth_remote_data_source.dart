import '../../../../core/network/dio_client.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource(this.dioClient);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dioClient.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<UserModel> getMe() async {
    final response = await dioClient.dio.get(
      '/auth/me',
    );

    return UserModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}