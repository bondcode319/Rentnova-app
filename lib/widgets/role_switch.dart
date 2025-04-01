// lib/widgets/role_switch.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/models/user.dart';
import 'package:rentnova/providers/user_provider.dart';

class RoleSwitchWidget extends StatelessWidget {
  const RoleSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    if (user == null) return const SizedBox();

    return PopupMenuButton<UserRole>(
      icon: const Icon(Icons.switch_account),
      onSelected: (role) async {
        try {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).switchRole(role);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error switching role: $e')));
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<UserRole>>[];

        // Only show tenant option if user has tenant profile and is not currently a tenant
        if (user.hasTenantProfile && user.role != UserRole.tenant) {
          items.add(
            const PopupMenuItem<UserRole>(
              value: UserRole.tenant,
              child: Text('Switch to Tenant'),
            ),
          );
        }

        // Only show landlord option if user has landlord profile and is not currently a landlord
        if (user.hasLandlordProfile && user.role != UserRole.landlord) {
          items.add(
            const PopupMenuItem<UserRole>(
              value: UserRole.landlord,
              child: Text('Switch to Landlord'),
            ),
          );
        }

        if (items.isEmpty) {
          items.add(
            const PopupMenuItem<UserRole>(
              enabled: false,
              child: Text('No other profiles'),
            ),
          );
        }

        return items;
      },
    );
  }
}
