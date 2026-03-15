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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final users = ref.watch(usersProvider);
    final filtered = _query.trim().isEmpty
        ? users
        : users.where((u) {
            final s = _query.toLowerCase();
            return u.name.toLowerCase().contains(s) || u.username.toLowerCase().contains(s) || u.employeeId.toLowerCase().contains(s) || u.designation.toLowerCase().contains(s);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.12),
                  colorScheme.secondary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Directory',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search and assign interfaces to your staff.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by name, username, employee ID, designation',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _search,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final u = filtered[index];
                final rolesText = (u.roles.isNotEmpty) ? u.roles.join(', ') : 'Unassigned';

                return GestureDetector(
                  onTap: () => _assignRole(u),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.surface,
                          theme.colorScheme.surfaceVariant.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              u.name.isNotEmpty ? u.name[0] : '?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        u.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      u.employeeId,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  u.designation,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: -6,
                                  children: (u.roles.isNotEmpty ? u.roles : const ['Unassigned']).map((r) {
                                    final isUnassigned = r.toLowerCase() == 'unassigned';
                                    return Chip(
                                      label: Text(r),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      backgroundColor: isUnassigned
                                          ? colorScheme.errorContainer.withOpacity(0.3)
                                          : colorScheme.primaryContainer.withOpacity(0.8),
                                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                                        color: isUnassigned ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.iconTheme.color?.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
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
