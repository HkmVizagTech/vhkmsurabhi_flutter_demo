// lib/features/admin/users/presentation/pages/create_user_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/app_text_field.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/injector.dart' as di;
import 'package:surabhi/core/constants/role_constants.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'volunteer';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return; // Prevent double submission

    setState(() => _isLoading = true);

    final api = di.sl<ApiClient>();
    try {
      final body = json.encode({
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text.trim(),
        'role': _role,
      });
      await api.dio.post(ApiConstants.userCreatePath, data: body);
      if (!mounted) return;
      UiUtils.showSnackBar(context, 'User created successfully', backgroundColor: AppColors.successColor);
      if (context.mounted) context.pop();
    } catch (e) {
      if (mounted) {
        UiUtils.showSnackBar(context, 'Failed to create user: $e', backgroundColor: AppColors.errorColor);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create User (Admin)',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
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
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (v) => (v != null && v.length >= 8) ? null : 'Min 8 chars',
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items: RoleConstants.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _role = v ?? 'volunteer'),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
