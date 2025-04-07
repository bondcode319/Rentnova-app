// lib/screens/tenant/maintenance/request_maintenance.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestMaintenanceScreen extends StatefulWidget {
  final String propertyId;

  const RequestMaintenanceScreen({super.key, required this.propertyId});

  @override
  State<RequestMaintenanceScreen> createState() =>
      _RequestMaintenanceScreenState();
}

class _RequestMaintenanceScreenState extends State<RequestMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory;
  List<String> _imageUrls = [];
  bool _consentGiven = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please describe the issue';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please specify location';
    }
    return null;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSubmitting = true);

      // Sanitize inputs
      final description = _descriptionController.text.trim();
      final location = _locationController.text.trim();

      await Provider.of<MaintenanceProvider>(
        context,
        listen: false,
      ).submitMaintenanceRequest(
        propertyId: widget.propertyId,
        category: _selectedCategory!,
        description: description,
        location: location,
        imageUrls: _imageUrls,
        consent: _consentGiven,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Maintenance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                          'Electrical',
                          'Plumbing',
                          'Security',
                          'Pest Control',
                          'Cleaning',
                          'Structural',
                          'Appliance',
                          'Other',
                        ]
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator:
                    (value) =>
                        value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location on Property*',
                  hintText: 'e.g., Master bathroom, Kitchen sink',
                  border: OutlineInputBorder(),
                ),
                validator: _validateLocation,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  hintText: 'Describe the issue in detail',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: _validateDescription,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Photos (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ImagePickerGrid(
                maxImages: 5,
                onImagesSelected:
                    (images) => setState(() => _imageUrls = images),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Grant access when not home'),
                subtitle: const Text(
                  'Allow technicians to enter when you\'re not present',
                ),
                value: _consentGiven,
                onChanged: (value) => setState(() => _consentGiven = value),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 45),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
