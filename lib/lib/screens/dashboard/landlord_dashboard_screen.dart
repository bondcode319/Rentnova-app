import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/lib/screens/dashboard/admin_dashboard_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';
import '../../widgets/confirm_dialog.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      await Provider.of<PropertyProvider>(
        context,
        listen: false,
      ).loadProperties();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to load properties: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to logout: $e');
    }
  }

  Future<void> _navigateToAddProperty() async {
    final result = await Navigator.pushNamed(context, '/add-property');
    if (result == true && mounted) {
      _loadProperties();
    }
  }

  Future<void> _handlePropertyUpdate(
    Property property,
    bool isAvailable,
  ) async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<PropertyProvider>(
        context,
        listen: false,
      ).updateProperty(property.id, {'isAvailable': isAvailable});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to update property: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePropertyDelete(Property property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => const ConfirmDialog(
            title: 'Delete Property',
            content:
                'Are you sure you want to delete this property? This action cannot be undone.',
            confirmText: 'Delete',
            confirmColor: Colors.red,
          ),
    );

    if (confirmed != true || !mounted) return;

    try {
      setState(() => _isLoading = true);
      await Provider.of<PropertyProvider>(
        context,
        listen: false,
      ).deleteProperty(property.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to delete property: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadProperties,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _handleLogout,
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoading || _isLoading) {
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
                    onPressed: _loadProperties,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final properties = propertyProvider.properties;
          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You haven\'t added any properties yet.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToAddProperty,
                    child: const Text('Add Property'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProperties,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return PropertyCard(
                  property: property,
                  onAvailabilityChanged:
                      (isAvailable) =>
                          _handlePropertyUpdate(property, isAvailable),
                  onEdit:
                      () => Navigator.pushNamed(
                        context,
                        '/edit-property',
                        arguments: property,
                      ),
                  onDelete: () => _handlePropertyDelete(property),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _navigateToAddProperty,
        child: const Icon(Icons.add),
      ),
    );
  }
}
