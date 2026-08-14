import 'package:flutter/material.dart';

import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();

  final dataSource = AuthRemoteDataSource(
    dioClient,
  );

  final repository = AuthRepositoryImpl(
    dataSource,
  );

  try {
    final result = await repository.login(
      email: 'tecnico@orbytis.com.br',
      password: '123456',
    );

    print('Token: ${result.accessToken}');
    print('Usuário: ${result.user.name}');
    print('Email: ${result.user.email}');
  } catch (e) {
    print('Erro: $e');
  }

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('API funcionando'),
        ),
      ),
    ),
  );
}