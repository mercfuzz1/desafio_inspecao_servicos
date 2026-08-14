import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
      user: UserModel.fromJson(json['user']),
    );
  }
}