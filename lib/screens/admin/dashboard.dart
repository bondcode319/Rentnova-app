// lib/screens/admin/dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/lib/models/property.dart';
import 'package:rentnova/providers/property_provider.dart';
import 'package:rentnova/providers/user_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (propertyProvider.error != null) {
            return Center(child: Text('Error: ${propertyProvider.error}'));
          }

          final properties = propertyProvider.properties;
          final pendingProperties =
              properties
                  .where((p) => p.status == PropertyStatus.pending)
                  .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(context, pendingProperties),
                const SizedBox(height: 20),
                _buildPendingProperties(context, pendingProperties),
                const SizedBox(height: 20),
                _buildAdminTools(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    List<Property> pendingProperties,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: pendingProperties.length,
                  label: 'Pending Listings',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/admin/pending_properties',
                      ),
                  semanticsLabel:
                      '${pendingProperties.length} Pending Listings',
                ),
                _StatItem(
                  value: 24,
                  label: 'Active Tenants',
                  semanticsLabel: '24 Active Tenants',
                ),
                _StatItem(
                  value: 5,
                  label: 'Pending Support',
                  semanticsLabel: '5 Pending Support Tickets',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingProperties(
    BuildContext context,
    List<Property> pendingProperties,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Property Approvals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (pendingProperties.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No pending properties to review'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingProperties.take(3).length,
            itemBuilder: (context, index) {
              final property = pendingProperties[index];
              return ListTile(
                title: Text(property.title),
                subtitle: Text(property.location),
                trailing: const Icon(Icons.arrow_forward),
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/admin/property_review',
                      arguments: property.id,
                    ),
              );
            },
          ),
        if (pendingProperties.length > 3)
          TextButton(
            onPressed:
                () => Navigator.pushNamed(context, '/admin/pending_properties'),
            child: const Text('View All Pending Properties'),
          ),
      ],
    );
  }

  Widget _buildAdminTools(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Tools',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _AdminToolItem(
              icon: Icons.people,
              label: 'User Management',
              onTap: () => Navigator.pushNamed(context, '/admin/users'),
            ),
            _AdminToolItem(
              icon: Icons.receipt,
              label: 'Payment Oversight',
              onTap: () => Navigator.pushNamed(context, '/admin/payments'),
            ),
            _AdminToolItem(
              icon: Icons.support_agent,
              label: 'Support Tickets',
              onTap: () => Navigator.pushNamed(context, '/admin/support'),
            ),
            _AdminToolItem(
              icon: Icons.settings,
              label: 'System Settings',
              onTap: () => Navigator.pushNamed(context, '/admin/settings'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  final String semanticsLabel;
  final VoidCallback? onTap;

  const _StatItem({
    required this.value,
    required this.label,
    required this.semanticsLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminToolItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminToolItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
