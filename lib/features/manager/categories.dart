import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared_folder/providers/categories_provider.dart';
import 'add_category.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3 / 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return Card(
            child: Center(child: Text(c['name'] as String)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCategoryPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
