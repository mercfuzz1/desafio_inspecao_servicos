import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/work_orders/data/datasources/work_orders_remote_data_source.dart';
import 'features/work_orders/data/repositories/work_orders_repository_impl.dart';
import 'features/work_orders/presentation/bloc/work_orders_bloc.dart';
import 'features/work_orders/presentation/bloc/work_orders_event.dart';
import 'features/work_orders/presentation/pages/work_orders_page.dart';

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final secureStorage = SecureStorage();

    final dioClient = DioClient(
      secureStorage: secureStorage,
    );

    final authRemoteDataSource =
        AuthRemoteDataSource(
      dioClient,
    );

    final AuthRepository authRepository =
        AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      secureStorage: secureStorage,
    );

    final workOrdersRemoteDataSource =
        WorkOrdersRemoteDataSource(
      dioClient,
    );

    final workOrdersRepository =
        WorkOrdersRepositoryImpl(
      remoteDataSource:
          workOrdersRemoteDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            repository: authRepository,
          )..add(
              const AuthStarted(),
            ),
        ),
        BlocProvider(
          create: (_) => WorkOrdersBloc(
            repository: workOrdersRepository,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Field Inspection',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            switch (state.status) {
              case AuthStatus.authenticated:
                return const WorkOrdersPage();

              case AuthStatus.unauthenticated:
              case AuthStatus.failure:
                return const LoginPage();

              case AuthStatus.initial:
              case AuthStatus.loading:
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}