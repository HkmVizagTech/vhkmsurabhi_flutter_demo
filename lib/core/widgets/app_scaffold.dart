// lib/core/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/role_based_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/features/employee/donor/presentation/pages/add_donor_page.dart';
import 'package:surabhi/features/preacher/enrolled_donors/presentation/pages/my_enrolled_donors_page.dart';
import 'package:surabhi/features/preacher/payment_link/presentation/pages/send_payment_link_page.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/donations_list_page.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/record_donation_page.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_lookup_page.dart';
import 'package:surabhi/features/volunteer/qr/presentation/pages/qr_scanner_page.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;
  // Optional bottom nav (dashboards only) - mirrors harekrishnavizag.org's
  // mobile pattern: a few important destinations plus a "More" that opens
  // the full drawer menu instead of navigating.
  final List<AppBottomNavItem>? bottomNavItems;
  final int bottomNavIndex;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.onLeadingPressed,
    this.bottomNavItems,
    this.bottomNavIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoleBasedAppBar(
        titleText: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')));
            },
          ),
          ...(actions ?? []),
        ],
        onLeadingPressed: onLeadingPressed,
      ),
      drawer: Drawer(child: _RoleAwareDrawer()),
      body: body,
      bottomNavigationBar: bottomNavItems == null
          ? null
          : Builder(
              builder: (scaffoldContext) => BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: bottomNavIndex,
                onTap: (i) {
                  final item = bottomNavItems![i];
                  if (item.isMore) {
                    Scaffold.of(scaffoldContext).openDrawer();
                  } else {
                    item.onTap?.call();
                  }
                },
                items: bottomNavItems!
                    .map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.label))
                    .toList(),
              ),
            ),
    );
  }
}

class _RoleAwareDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return _buildUnauthenticatedDrawer(context);
        }

        final user = authState.user;
        final theme = Theme.of(context);

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context, user, theme),
            _buildDashboardTile(context, user.role),
            ..._buildRoleSpecificTiles(context, user.role),
            const Divider(),
            ..._buildCommonTiles(context),
            _buildThemeToggle(context),
            _buildLogoutTile(context),
          ],
        );
      },
    );
  }

  Widget _buildUnauthenticatedDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildUnauthenticatedHeader(context, theme),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.of(context).pop();
            context.go('/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          onTap: () {
            Navigator.of(context).pop();
            context.go('/login');
          },
        ),
        const Divider(),
        _buildThemeToggle(context),
      ],
    );
  }

  Widget _buildUnauthenticatedHeader(BuildContext context, ThemeData theme) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(Icons.person_outline, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Surabhi',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text('Please login to continue', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, dynamic user, ThemeData theme) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: user.image != null && (user.image as String).isNotEmpty
                    ? NetworkImage(user.image as String)
                    : null,
                child: user.image == null || (user.image as String?)?.isEmpty == true
                    ? Text(
                        (user.email as String).isNotEmpty ? (user.email as String)[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.firstName != null && user.lastName != null
                          ? '${user.firstName} ${user.lastName}'
                          : user.email as String,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      (user.role as String).toUpperCase(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.email as String,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, String role) {
    return ListTile(
      leading: const Icon(Icons.dashboard),
      title: const Text('Dashboard'),
      onTap: () {
        Navigator.of(context).pop(); // close the drawer
        // Drop any screens pushed on top of the dashboard (e.g. a "coming
        // soon" detail page) first: otherwise context.go() to a path we're
        // already logically on is a no-op and the pushed page stays put.
        Navigator.of(context).popUntil((route) => route.isFirst);
        _navigateToDashboard(context, role);
      },
    );
  }

  List<Widget> _buildRoleSpecificTiles(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/admin-dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Register User'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/admin/create-user');
            },
          ),
        ];
      case 'employee':
        {
          const employeeColor = AppColors.employeeColor;
          return [
            _pageTile(context, Icons.person_add, 'Add Donor', const AddDonorPage()),
            _pageTile(context, Icons.person_search, 'Search Donor', const DonorLookupPage(color: employeeColor)),
            _pageTile(
              context,
              Icons.receipt_long,
              'Record Donation',
              const RecordDonationPage(title: 'Record Donation', color: employeeColor),
            ),
            _pageTile(
              context,
              Icons.bar_chart,
              'Donations Report',
              const DonationsListPage(title: 'Donations Report', color: employeeColor),
            ),
          ];
        }
      case 'preacher':
        {
          const preacherColor = AppColors.preacherColor;
          return [
            _pageTile(
              context,
              Icons.person_add,
              'Add Donor',
              const AddDonorPage(title: 'Add Donor', color: preacherColor),
            ),
            _pageTile(
              context,
              Icons.person_search,
              'Search Donor',
              const DonorLookupPage(color: preacherColor, enrolledByFilter: kCurrentPreacherCode),
            ),
            _pageTile(
              context,
              Icons.receipt_long,
              'Make Receipt',
              const RecordDonationPage(title: 'Make Receipt', color: preacherColor),
            ),
            _pageTile(context, Icons.groups, 'My Enrolled Donors', const MyEnrolledDonorsPage()),
            _pageTile(context, Icons.link, 'Send Payment Link', const SendPaymentLinkPage()),
          ];
        }
      case 'approver':
        {
          const approverColor = AppColors.approverColor;
          return [
            _pageTile(
              context,
              Icons.pending_actions,
              'Pending Approvals',
              const DonationsListPage(
                title: 'Pending Approvals',
                color: approverColor,
                statusFilter: DonationStatus.pending,
                showApproveAction: true,
              ),
            ),
            _pageTile(
              context,
              Icons.history,
              'Approval History',
              const DonationsListPage(
                title: 'Approval History',
                color: approverColor,
                statusFilter: DonationStatus.approved,
              ),
            ),
          ];
        }
      case 'volunteer':
        {
          const volunteerColor = AppColors.volunteerColor;
          return [
            _pageTile(context, Icons.person_search, 'Search Donor', const DonorLookupPage(color: volunteerColor)),
            _pageTile(context, Icons.qr_code_scanner, 'QR Code Scanner', const QrScannerPage()),
          ];
        }
      default:
        return [];
    }
  }

  ListTile _pageTile(BuildContext context, IconData icon, String label, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  List<Widget> _buildCommonTiles(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.of(context).pop();
          context.push('/settings');
        },
      ),
    ];
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return ListTile(
          leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          title: Row(
            children: [
              const Expanded(child: Text('Dark Mode')),
              Switch(
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme(value);
                },
              ),
            ],
          ),
          onTap: null, // Disable tap on the entire tile
        );
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
      title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      onTap: () {
        Navigator.of(context).pop();
        _showLogoutConfirmation(context);
      },
    );
  }

  void _navigateToDashboard(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        context.go('/admin-dashboard');
        break;
      case 'employee':
        context.go('/employee-dashboard');
        break;
      case 'preacher':
        context.go('/preacher-dashboard');
        break;
      case 'approver':
        context.go('/approver-dashboard');
        break;
      case 'volunteer':
        context.go('/volunteer-dashboard');
        break;
      default:
        context.go('/home');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
                context.read<AuthBloc>().add(LogoutRequested());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            ),
          ],
        );
      },
    );
  }
}
