import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';

class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = Provider.of<PropertyProvider>(context).properties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body:
          properties.isEmpty
              ? const Center(child: Text('No available properties found.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (property.images != null &&
                            property.images!.isNotEmpty)
                          Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.home,
                                size: 80,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                property.address,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${property.rent.toStringAsFixed(2)} / month',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (property.description != null)
                                Text(property.description!),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    property.amenities.map((amenity) {
                                      return Chip(
                                        label: Text(amenity),
                                        backgroundColor: Colors.blue[50],
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Show property details
                                },
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
