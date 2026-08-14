import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/presentation/bloc/auth_bloc.dart';
import 'auth/presentation/bloc/auth_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthLogoutRequested(),
                  );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Olá, ${user?.name ?? ''}',
        ),
      ),
    );
  }
}