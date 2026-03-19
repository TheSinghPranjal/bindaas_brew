import 'package:flutter/material.dart';

import '../../features/admin/super_admin_dashboard.dart';
import '../../features/manager/manager_dashboard.dart';
import '../../features/roles/admin_interface.dart';
import '../../features/roles/chef_interface.dart';
import '../../features/roles/cleaning_interface.dart';
import '../../features/roles/head_chef_interface.dart';
import '../../features/roles/inventory_interface.dart';
import '../../features/roles/kitchen_interface.dart';
import '../../features/roles/senior_waiter_interface.dart';
import '../../features/roles/service_desk_interface.dart';
import '../../features/roles/waiter_interface.dart';

enum DashboardDestination {
  superAdmin,
  admin,
  manager,
  headChef,
  chef,
  kitchen,
  seniorWaiter,
  waiter,
  serviceDesk,
  cleaning,
  inventory,
}

class DashboardSwitcher extends StatelessWidget {
  const DashboardSwitcher({
    super.key,
    this.label = 'Dashboards',
    this.tooltip = 'Open dashboard',
    this.push = true,
  });

  final String label;
  final String tooltip;

  /// When true, use `Navigator.push(...)` (default). When false, use `pushReplacement(...)`.
  final bool push;

  static const List<(DashboardDestination, String)> items = [
    (DashboardDestination.superAdmin, 'Super Admin Dashboard'),
    (DashboardDestination.admin, 'Admin Dashboard'),
    (DashboardDestination.manager, 'Manager Dashboard'),
    (DashboardDestination.headChef, 'Head Chef Dashboard'),
    (DashboardDestination.chef, 'Chef Dashboard'),
    (DashboardDestination.kitchen, 'Kitchen Dashboard'),
    (DashboardDestination.seniorWaiter, 'Senior Waiter Dashboard'),
    (DashboardDestination.waiter, 'Waiter Dashboard'),
    (DashboardDestination.serviceDesk, 'Service Desk Dashboard'),
    (DashboardDestination.cleaning, 'Cleaning Dashboard'),
    (DashboardDestination.inventory, 'Inventory Dashboard'),
  ];

  static Widget screenFor(DashboardDestination d) {
    switch (d) {
      case DashboardDestination.superAdmin:
        return const SuperAdminDashboard();
      case DashboardDestination.admin:
        return const AdminInterface();
      case DashboardDestination.manager:
        return const ManagerDashboard();
      case DashboardDestination.headChef:
        return const HeadChefInterface();
      case DashboardDestination.chef:
        return const ChefInterface();
      case DashboardDestination.kitchen:
        return const KitchenInterface();
      case DashboardDestination.seniorWaiter:
        return const SeniorWaiterInterface();
      case DashboardDestination.waiter:
        return const WaiterInterface();
      case DashboardDestination.serviceDesk:
        return const ServiceDeskInterface();
      case DashboardDestination.cleaning:
        return const CleaningInterface();
      case DashboardDestination.inventory:
        return const InventoryInterface();
    }
  }

  void _open(BuildContext context, DashboardDestination d) {
    final route = MaterialPageRoute(builder: (_) => screenFor(d));
    if (push) {
      Navigator.of(context).push(route);
    } else {
      Navigator.of(context).pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DashboardDestination>(
      tooltip: tooltip,
      onSelected: (d) => _open(context, d),
      itemBuilder: (context) => items
          .map(
            (i) => PopupMenuItem<DashboardDestination>(
              value: i.$1,
              child: Text(i.$2),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.dashboard_customize_outlined),
            const SizedBox(width: 6),
            Text(label),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

