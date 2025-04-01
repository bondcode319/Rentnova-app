import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';
import '../../models/user.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/error_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<PropertyProvider>(
        context,
        listen: false,
      ).loadProperties();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error logging out: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Properties'), Tab(text: 'Users')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [PropertiesTab(), UsersTab()],
      ),
    );
  }
}

class PropertiesTab extends StatelessWidget {
  const PropertiesTab({Key? key}) : super(key: key);

  Future<void> _handleDeleteProperty(
    BuildContext context,
    PropertyProvider provider,
    Property property,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: 'Delete Property',
            content:
                'Are you sure you want to delete "${property.name}"? This action cannot be undone.',
            confirmText: 'Delete',
            confirmColor: Colors.red,
          ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await provider.deleteProperty(property.id);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete property: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, child) {
        if (propertyProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (propertyProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${propertyProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => propertyProvider.loadProperties(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final properties = propertyProvider.properties;
        if (properties.isEmpty) {
          return const Center(child: Text('No properties found.'));
        }

        return RefreshIndicator(
          onRefresh: () => propertyProvider.loadProperties(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                property: property,
                onDelete:
                    () => _handleDeleteProperty(
                      context,
                      propertyProvider,
                      property,
                    ),
                onView:
                    () => Navigator.pushNamed(
                      context,
                      '/admin/property/${property.id}',
                    ),
              );
            },
          ),
        );
      },
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const PropertyCard({
    Key? key,
    required this.property,
    required this.onDelete,
    required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    property.name,
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            _buildPropertyDetails(theme),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        property.status.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: _getStatusColor(property.status)),
      ),
      backgroundColor: _getStatusColor(property.status).withOpacity(0.1),
    );
  }

  Widget _buildPropertyDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.location_on, 'Address:', property.address, theme),
        _buildDetailRow(
          Icons.attach_money,
          'Rent:',
          '₦${property.rent.toStringAsFixed(2)}',
          theme,
        ),
        _buildDetailRow(Icons.person, 'Owner ID:', property.ownerId, theme),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onView,
          icon: const Icon(Icons.visibility),
          label: const Text('View Details'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Delete'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.available:
        return Colors.green;
      case PropertyStatus.pending:
        return Colors.orange;
      case PropertyStatus.rented:
        return Colors.blue;
      case PropertyStatus.unavailable:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
