// lib/screens/tenant/lease/lease_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/models/lease.dart';
import 'package:rentnova/providers/lease_provider.dart';
import 'package:rentnova/widgets/pdf_viewer.dart';

class LeaseViewScreen extends StatefulWidget {
  final String leaseId;

  const LeaseViewScreen({super.key, required this.leaseId});

  @override
  State<LeaseViewScreen> createState() => _LeaseViewScreenState();
}

class _LeaseViewScreenState extends State<LeaseViewScreen> {
  bool _isSigning = false;
  bool _isLoading = true;
  String? _error;
  LeaseAgreement? _lease;

  @override
  void initState() {
    super.initState();
    _loadLease();
  }

  Future<void> _loadLease() async {
    try {
      final lease = await Provider.of<LeaseProvider>(
        context,
        listen: false,
      ).getLeaseById(widget.leaseId);

      if (!mounted) return;

      setState(() {
        _lease = lease;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    if (_lease == null) {
      return const Scaffold(body: Center(child: Text('Lease not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lease Agreement'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLease),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: PDFViewerWidget(pdfUrl: _lease!.documentUrl)),
          if (_lease!.signedDate == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isSigning ? null : () => _signLease(_lease!),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    _isSigning
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Sign Lease Agreement'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _signLease(LeaseAgreement lease) async {
    if (_isSigning) return;

    setState(() => _isSigning = true);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirm Lease Signing'),
              content: const Text(
                'Are you sure you want to sign this lease agreement? This action is legally binding and cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sign'),
                ),
              ],
            ),
      );

      if (!mounted) return;

      if (confirmed == true) {
        await Provider.of<LeaseProvider>(
          context,
          listen: false,
        ).signLease(lease.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lease signed successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh lease data after signing
        await _loadLease();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing lease: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigning = false);
      }
    }
  }
}
