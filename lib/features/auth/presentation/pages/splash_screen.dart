// lib/features/auth/presentation/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/app_bar_actions.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/routes/app_navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch AppStarted event to check authentication status after the UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<AuthBloc>(context).add(AppStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Surabhi',
      actions: [AppBarActions.loginButton(context)],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppNavigator.navigateBasedOnRole(context, state.user.role);
          } else if (state is AuthUnauthenticated) {
            // No-op; router redirect will handle
          } else if (state is AuthError) {
            UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
            AppNavigator.navigateToLogin(context); // Redirect to login on error
          }
          // No action needed for AuthInitial or AuthLoading, just show indicator
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(), SizedBox(height: 20), Text('Checking authentication status...')],
          ),
        ),
      ),
    );
  }
}
