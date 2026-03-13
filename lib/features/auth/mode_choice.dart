import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin/super_admin_dashboard.dart';
import '../customer/customer_home.dart';
import '../manager/manager_dashboard.dart';

import '../../shared_folder/providers/current_role_provider.dart';
import '../../shared_folder/models/role.dart';

import '../roles/admin_interface.dart';
import '../roles/head_chef_interface.dart';
import '../roles/chef_interface.dart';
import '../roles/kitchen_interface.dart';
import '../roles/senior_waiter_interface.dart';
import '../roles/waiter_interface.dart';
import '../roles/service_desk_interface.dart';
import '../roles/cleaning_interface.dart';
import '../roles/inventory_interface.dart';
import '../roles/user_interface.dart';

class ModeChoice extends ConsumerWidget {
  const ModeChoice({super.key});

  /// Returns widget for role
  Widget _widgetForRole(Role? role) {
    switch (role) {
      case Role.superAdmin:
        return const SuperAdminDashboard();

      case Role.admin:
        return const AdminInterface();

      case Role.manager:
        return const ManagerDashboard();

      case Role.headChef:
        return const HeadChefInterface();

      case Role.chef:
        return const ChefInterface();

      case Role.kitchen:
        return const KitchenInterface();

      case Role.seniorWaiter:
        return const SeniorWaiterInterface();

      case Role.waiter:
        return const WaiterInterface();

      case Role.serviceDesk:
        return const ServiceDeskInterface();

      case Role.cleaning:
        return const CleaningInterface();

      case Role.inventory:
        return const InventoryInterface();

      case Role.customer:
        return const UserInterface();

      default:
        return const ManagerDashboard();
    }
  }

  /// Label for tab
  String _labelForRole(Role role) {
    switch (role) {
      case Role.superAdmin:
        return 'Super Admin';

      case Role.admin:
        return 'Admin';

      case Role.manager:
        return 'Manager';

      case Role.headChef:
        return 'Head Chef';

      case Role.chef:
        return 'Chef';

      case Role.kitchen:
        return 'Kitchen';

      case Role.seniorWaiter:
        return 'Senior Waiter';

      case Role.waiter:
        return 'Waiter';

      case Role.serviceDesk:
        return 'Service Desk';

      case Role.cleaning:
        return 'Cleaning';

      case Role.inventory:
        return 'Inventory';

      case Role.customer:
        return 'Customer';
    }
  }

  /// Manual mode chooser (if roles not assigned)
  Widget _manualModeChooser(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dive Deep As?')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const CustomerHome(),
                  ),
                );
              },
              child: const Text('Customer'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const ManagerDashboard(),
                  ),
                );
              },
              child: const Text('Restaurant'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(currentRolesProvider);

    /// If roles not defined
    if (roles.isEmpty) {
      return _manualModeChooser(context);
    }

    /// If single role
    if (roles.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _widgetForRole(roles.first),
          ),
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// Multiple roles -> show tabs
    return DefaultTabController(
      length: roles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Role'),
          bottom: TabBar(
            isScrollable: true,
            tabs: roles.map((r) => Tab(text: _labelForRole(r))).toList(),
          ),
        ),
        body: TabBarView(
          children: roles.map((r) => _widgetForRole(r)).toList(),
        ),
      ),
    );
  }
}