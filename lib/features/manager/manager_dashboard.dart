import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'categories.dart';
import 'products.dart';
import '../../shared_folder/providers/users_provider.dart';
import '../../shared_folder/providers/categories_provider.dart';
import '../../shared_folder/providers/products_provider.dart';

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _card(context, 'Users', Icons.people, () {}, count: users.length),
            _card(context, 'Categories', Icons.category, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesPage())), count: categories.length),
            _card(context, 'Products', Icons.fastfood, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsPage())), count: products.length),
            _card(context, 'Notifications', Icons.notifications, () {}, count: 0),
            _card(context, 'Events', Icons.event, () {}, count: 0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _card(BuildContext ctx, String title, IconData icon, VoidCallback onTap, {int? count}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(title),
              if (count != null) ...[
                const SizedBox(height: 6),
                Chip(label: Text(count.toString())),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
