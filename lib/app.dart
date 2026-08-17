import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/app_database.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

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
import 'features/work_orders/presentation/pages/work_orders_page.dart';
import 'features/work_orders/data/datasources/work_orders_local_data_source.dart';

import 'features/inspections/data/datasources/inspections_local_data_source.dart';
import 'features/inspections/data/datasources/inspections_remote_data_source.dart';
import 'features/inspections/data/repositories/inspections_repository_impl.dart';
import 'features/inspections/domain/repositories/inspections_repository.dart';
import 'features/inspections/presentation/bloc/inspections_history_bloc.dart';

import 'features/sync/data/services/sync_service_impl.dart';
import 'features/sync/domain/services/sync_service.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ThemeController themeController;

  @override
  void initState() {
    super.initState();

    themeController = ThemeController();
  }

  @override
  void dispose() {
    themeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ==================================================
    // CORE
    // ==================================================

    final secureStorage = SecureStorage();

    final dioClient = DioClient(secureStorage: secureStorage);

    final database = AppDatabase();

    final workOrdersDao = database.workOrdersDao;
    
    // ==================================================
    // AUTH
    // ==================================================

    final authRemoteDataSource = AuthRemoteDataSource(dioClient);

    final AuthRepository authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      secureStorage: secureStorage,
    );

    // ==================================================
    // WORK ORDERS
    // ==================================================

    final workOrdersRemoteDataSource = WorkOrdersRemoteDataSource(dioClient);

    final workOrdersLocalDataSource = WorkOrdersLocalDataSource(
      dao: workOrdersDao,
    );

    final workOrdersRepository = WorkOrdersRepositoryImpl(
      remoteDataSource: workOrdersRemoteDataSource,
      localDataSource: workOrdersLocalDataSource,
    );

    // ==================================================
    // INSPECTIONS
    // ==================================================

    final inspectionsDao = database.inspectionsDao;

    final inspectionsLocalDataSource = InspectionsLocalDataSource(
      dao: inspectionsDao,
    );

    final inspectionsRemoteDataSource = InspectionsRemoteDataSource(dioClient);

    final InspectionsRepository inspectionsRepository =
        InspectionsRepositoryImpl(
          localDataSource: inspectionsLocalDataSource,
          remoteDataSource: inspectionsRemoteDataSource,
        );

    // ==================================================
    // SYNC
    // ==================================================

    final SyncService syncService = SyncServiceImpl(
      inspectionsRepository: inspectionsRepository,
    );

    final connectivityService = ConnectivityService();

    // ==================================================
    // PROVIDERS
    // ==================================================

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InspectionsRepository>.value(
          value: inspectionsRepository,
        ),

        RepositoryProvider<SyncService>.value(value: syncService),
      ],

      child: MultiBlocProvider(
        providers: [
          // ==================================================
          // AUTH BLOC
          // ==================================================

          BlocProvider(
            create: (_) =>
                AuthBloc(repository: authRepository)..add(const AuthStarted()),
          ),

          // ==================================================
          // WORK ORDERS BLOC
          // ==================================================
          BlocProvider(
            create: (_) => WorkOrdersBloc(repository: workOrdersRepository),
          ),

          // ==================================================
          // SYNC BLOC
          // ==================================================
          BlocProvider(
            create: (_) => SyncBloc(
              syncService: syncService,
              connectivityService: connectivityService,
            ),
          ),

          // ==================================================
          // INSPECTIONS HISTORY BLOC
          // ==================================================
          BlocProvider(
            create: (_) =>
                InspectionsHistoryBloc(repository: inspectionsRepository),
          ),
        ],

        // ==================================================
        // MATERIAL APP
        // ==================================================
        child: AnimatedBuilder(
          animation: themeController,

          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              title: 'Field Inspection',

              // ==================================================
              // THEME
              // ==================================================
              theme: AppTheme.light,

              darkTheme: AppTheme.dark,

              themeMode: themeController.themeMode,

              // ==================================================
              // HOME
              // ==================================================
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  switch (state.status) {
                    case AuthStatus.authenticated:
                      return WorkOrdersPage(
                        inspectionsRepository: context
                            .read<InspectionsRepository>(),

                        themeController: themeController,
                      );

                    case AuthStatus.unauthenticated:
                    case AuthStatus.failure:
                      return const LoginPage();

                    case AuthStatus.initial:
                    case AuthStatus.loading:
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
