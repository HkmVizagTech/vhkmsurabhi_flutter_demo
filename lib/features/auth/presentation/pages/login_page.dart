// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/app_text_field.dart';
import 'package:surabhi/core/widgets/loading_indicator.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/routes/app_navigator.dart';
import 'package:surabhi/core/utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(email: _emailController.text.trim().toLowerCase(), password: _passwordController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      actions: const [],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppNavigator.navigateBasedOnRole(context, state.user.role);
          } else if (state is AuthError) {
            UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.emailValidator,
                  prefixIcon: const Icon(Icons.email),
                  onChanged: (value) {
                    // Auto-convert to lowercase as user types
                    final lowercaseValue = value.toLowerCase();
                    if (value != lowercaseValue) {
                      _emailController.value = _emailController.value.copyWith(
                        text: lowercaseValue,
                        selection: TextSelection.collapsed(offset: lowercaseValue.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: AppValidators.passwordValidator,
                  prefixIcon: const Icon(Icons.lock),
                ),
                const SizedBox(height: 24.0),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return state is AuthLoading
                        ? const AppLoadingIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // Make button full width
                            ),
                            child: const Text('Login', style: TextStyle(fontSize: 18)),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
