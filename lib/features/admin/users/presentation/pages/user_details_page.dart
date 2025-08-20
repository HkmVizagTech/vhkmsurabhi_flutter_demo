// lib/features/admin/users/presentation/pages/user_details_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class UserDetailsPage extends StatelessWidget {
  final UserEntity user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'User Details',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar and Basic Info
            _buildUserHeader(context, theme),

            const SizedBox(height: 24),

            // User Information Cards
            _buildInfoCard(context, 'Personal Information', [
              _buildInfoRow('First Name', user.firstName ?? 'Not provided'),
              _buildInfoRow('Last Name', user.lastName ?? 'Not provided'),
              _buildInfoRow('Email', user.email),
              _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
            ]),

            const SizedBox(height: 16),

            _buildInfoCard(context, 'Account Information', [
              _buildInfoRow('User ID', user.userId),
              _buildInfoRow('Role', user.role.toUpperCase()),
              _buildInfoRow('2FA Enabled', user.is2faEnabled ? 'Yes' : 'No'),
            ]),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundImage: user.image != null && user.image!.isNotEmpty ? NetworkImage(user.image!) : null,
              child: user.image == null || user.image!.isEmpty
                  ? Text(
                      user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),

            const SizedBox(width: 20),

            // Basic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.firstName != null && user.lastName != null ? '${user.firstName} ${user.lastName}' : user.email,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRoleColor(user.role)),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // 2FA Status
            if (user.is2faEnabled)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getSecurityColor(user.is2faEnabled).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.security, color: AppColors.getSecurityColor(user.is2faEnabled), size: 24),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement edit user functionality
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Edit user functionality coming soon')));
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit User'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.mounted) {
                context.pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to List'),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    return AppColors.getRoleColor(role);
  }
}
