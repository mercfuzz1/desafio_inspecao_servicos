import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state.status == AuthStatus.loading;
                final hasError = state.status == AuthStatus.failure;
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.assignment_rounded,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Orbytis - Inspect Manager',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acesse sua conta para continuar',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'Digite seu e-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) {
                            if (!isLoading) {
                              _login();
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (hasError) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.errorMessage ??
                                        'E-mail ou senha inválidos.',
                                    style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : _login,
                            child: isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
