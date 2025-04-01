import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/models/user.dart';
import 'package:rentnova/providers/user_provider.dart';
import 'package:rentnova/widgets/role_switch.dart';

class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Dashboard'),
        actions: const [RoleSwitchWidget()],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Please sign in to continue'));
          }

          if (user.role != UserRole.tenant) {
            return const Center(child: Text('Invalid user role'));
          }

          return RefreshIndicator(
            onRefresh: () => userProvider.refreshUserData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(user),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildActiveLeases(),
                  const SizedBox(height: 24),
                  _buildRecentPayments(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tenant ID: ${user.id}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _QuickActionCard(
              icon: Icons.receipt,
              label: 'Pay Rent',
              onTap:
                  (context) => Navigator.pushNamed(context, '/tenant/payments'),
            ),
            _QuickActionCard(
              icon: Icons.build,
              label: 'Maintenance',
              onTap:
                  (context) =>
                      Navigator.pushNamed(context, '/tenant/maintenance'),
            ),
            _QuickActionCard(
              icon: Icons.message,
              label: 'Messages',
              onTap:
                  (context) => Navigator.pushNamed(context, '/tenant/messages'),
            ),
            _QuickActionCard(
              icon: Icons.description,
              label: 'Documents',
              onTap:
                  (context) =>
                      Navigator.pushNamed(context, '/tenant/documents'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveLeases() {
    // TODO: Implement active leases section
    return const SizedBox();
  }

  Widget _buildRecentPayments() {
    // TODO: Implement recent payments section
    return const SizedBox();
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(BuildContext) onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
