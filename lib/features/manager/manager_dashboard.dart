import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'categories.dart';
import 'products.dart';
import '../../shared_folder/providers/users_provider.dart';
import '../../shared_folder/providers/categories_provider.dart';
import '../../shared_folder/providers/products_provider.dart';
import '../../shared_folder/widgets/dashboard_switcher.dart';

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  void _openDashboard(BuildContext context, DashboardDestination d) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DashboardSwitcher.screenFor(d)),
    );
  }

  Widget _restaurantDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.18),
                    theme.colorScheme.secondary.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    child: Icon(Icons.storefront_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 10),
                  Text('Restaurant', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Manager Dashboard', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.category_rounded),
              title: const Text('Categories'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood_rounded),
              title: const Text('Products'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsPage()));
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Text('Dashboards', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            ...DashboardSwitcher.items.map(
              (i) => ListTile(
                dense: true,
                leading: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                title: Text(i.$2),
                onTap: () {
                  Navigator.of(context).pop();
                  _openDashboard(context, i.$1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final users = ref.watch(usersProvider);
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      drawer: _restaurantDrawer(context),
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: const [
          DashboardSwitcher(),
        ],
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
                  'Restaurant Console',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quickly manage categories, menu items, events and more.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _statChip(
                      context,
                      label: 'Team',
                      icon: Icons.people_alt_rounded,
                      value: users.length.toString(),
                    ),
                    _statChip(
                      context,
                      label: 'Categories',
                      icon: Icons.category_outlined,
                      value: categories.length.toString(),
                    ),
                    _statChip(
                      context,
                      label: 'Products',
                      icon: Icons.fastfood_rounded,
                      value: products.length.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _card(
                    context,
                    title: 'Users',
                    icon: Icons.people_rounded,
                    color: colorScheme.primary,
                    onTap: () {},
                    count: users.length,
                  ),
                  _card(
                    context,
                    title: 'Categories',
                    icon: Icons.category_rounded,
                    color: colorScheme.secondary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CategoriesPage()),
                    ),
                    count: categories.length,
                  ),
                  _card(
                    context,
                    title: 'Products',
                    icon: Icons.fastfood_rounded,
                    color: colorScheme.tertiary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductsPage()),
                    ),
                    count: products.length,
                  ),
                  _card(
                    context,
                    title: 'Notifications',
                    icon: Icons.notifications_active_rounded,
                    color: colorScheme.error,
                    onTap: () {},
                    count: 0,
                  ),
                  _card(
                    context,
                    title: 'Events',
                    icon: Icons.event_rounded,
                    color: colorScheme.primaryContainer,
                    onTap: () {},
                    count: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Quick action'),
      ),
    );
  }

  Widget _card(
    BuildContext ctx, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int? count,
  }) {
    final theme = Theme.of(ctx);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.16),
              color.withOpacity(0.28),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 36,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count items',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, {required String label, required IconData icon, required String value}) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.4)),
    );
  }
}
