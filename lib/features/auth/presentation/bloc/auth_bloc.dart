import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({
    required this.repository,
  }) : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

Future<void> _onAuthStarted(
  AuthStarted event,
  Emitter<AuthState> emit,
) async {
  emit(
    state.copyWith(
      status: AuthStatus.loading,
    ),
  );

  try {
    final hasSession = await repository.hasSession();

    if (!hasSession) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
      );

      return;
    }

    final user = await repository.restoreSession();

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  } catch (_) {
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
      ),
    );
  }
}

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
      ),
    );

    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'E-mail ou senha inválidos.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();

    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
      ),
    );
  }
}