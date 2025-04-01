// lib/screens/tenant/application/application_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/models/property.dart';
import 'package:rentnova/providers/application_provider.dart';
import 'package:rentnova/widgets/document_upload.dart';

class ApplicationFormScreen extends StatefulWidget {
  final PropertyModel property;

  const ApplicationFormScreen({super.key, required this.property});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employmentController = TextEditingController();
  final _employerController = TextEditingController();
  final _salaryController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinPhoneController = TextEditingController();
  final _moveInDateController = TextEditingController();
  final _durationController = TextEditingController();

  String? _employmentStatus;
  List<String> _documentUrls = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _employmentController.dispose();
    _employerController.dispose();
    _salaryController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinPhoneController.dispose();
    _moveInDateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Please enter a valid 11-digit phone number';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Application')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Applying for ${widget.property.title}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('Name: ${user?.fullName ?? ''}'),
              Text('Email: ${user?.email ?? ''}'),
              Text('Phone: ${user?.phoneNumber ?? ''}'),
              Text('NIN: ${user?.nin ?? ''}'),
              const Divider(),
              const Text(
                'Employment Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              DropdownButtonFormField<String>(
                value: _employmentStatus,
                decoration: const InputDecoration(
                  labelText: 'Employment Status*',
                ),
                items:
                    ['Employed', 'Self-Employed', 'Student', 'Unemployed'].map((
                      status,
                    ) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _employmentStatus = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select employment status';
                  }
                  return null;
                },
              ),
              if (_employmentStatus == 'Employed' ||
                  _employmentStatus == 'Self-Employed') ...[
                TextFormField(
                  controller: _employerController,
                  decoration: const InputDecoration(
                    labelText: 'Employer/Business Name*',
                  ),
                  validator: (value) {
                    if ((_employmentStatus == 'Employed' ||
                            _employmentStatus == 'Self-Employed') &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter employer/business name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Income*',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if ((_employmentStatus == 'Employed' ||
                            _employmentStatus == 'Self-Employed') &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter monthly income';
                    }
                    return null;
                  },
                ),
              ],
              const Divider(),
              const Text(
                'Guarantor Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextFormField(
                controller: _guarantorNameController,
                decoration: const InputDecoration(labelText: 'Full Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter guarantor name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _guarantorPhoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const Divider(),
              const Text(
                'Next of Kin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextFormField(
                controller: _nextOfKinNameController,
                decoration: const InputDecoration(labelText: 'Full Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter next of kin name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nextOfKinPhoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const Divider(),
              const Text(
                'Lease Preferences',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextFormField(
                controller: _moveInDateController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Move-in Date*',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _moveInDateController.text =
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select move-in date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Lease Duration (months)*',
                ),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const Divider(),
              const Text(
                'Required Documents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload: Valid ID, Proof of Income, Bank Statement',
              ),
              DocumentUploadWidget(
                onDocumentsUploaded: (urls) {
                  setState(() => _documentUrls = urls);
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Submit Application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_documentUrls.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rentalProfile = {
        'employmentStatus': _employmentStatus,
        'employer': _employerController.text.trim(),
        'monthlyIncome': _salaryController.text.trim(),
        'guarantorName': _guarantorNameController.text.trim(),
        'guarantorPhone': _guarantorPhoneController.text.trim(),
        'nextOfKinName': _nextOfKinNameController.text.trim(),
        'nextOfKinPhone': _nextOfKinPhoneController.text.trim(),
        'moveInDate': _moveInDateController.text,
        'leaseDuration': _durationController.text.trim(),
      };

      await Provider.of<ApplicationProvider>(
        context,
        listen: false,
      ).submitApplication(
        propertyId: widget.property.id,
        rentalProfile: rentalProfile,
        documentUrls: _documentUrls,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
