import '../../../../core/network/dio_client.dart';
import '../../models/auth_response_model.dart';

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

    return AuthResponseModel.fromJson(response.data);
  }
}