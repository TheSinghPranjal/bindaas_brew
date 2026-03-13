import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared_folder/models/user.dart';
import '../../shared_folder/providers/users_provider.dart';

const List<String> availableRoles = [
  'Admin',
  'Manager',
  'Head Chef',
  'Chef',
  'Kitchen Staff',
  'Senior Waiter',
  'Waiter',
  'Service Desk',
  'Cleaning Staff',
  'Inventory Manager',
];

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  ConsumerState<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard> {
  String _query = '';

  void _search(String q) {
    setState(() => _query = q);
  }

  void _assignRole(User user) async {
    final role = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Assign Role'),
        children: availableRoles.map((r) => SimpleDialogOption(onPressed: () => Navigator.of(ctx).pop(r), child: Text(r))).toList(),
      ),
    );

    if (role != null) {
      ref.read(usersProvider.notifier).addRole(user.employeeId, role);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added role $role to ${user.name}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final filtered = _query.trim().isEmpty
        ? users
        : users.where((u) {
            final s = _query.toLowerCase();
            return u.name.toLowerCase().contains(s) || u.username.toLowerCase().contains(s) || u.employeeId.toLowerCase().contains(s) || u.designation.toLowerCase().contains(s);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin Dashboard')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name, username, employeeId, designation'),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final u = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(u.name.isNotEmpty ? u.name[0] : '?')),
                    title: Text(u.name),
                    subtitle: Text('${u.designation} • ${u.employeeId}'),
                    trailing: Text((u.roles.isNotEmpty) ? u.roles.join(', ') : 'Unassigned'),
                    onTap: () => _assignRole(u),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
