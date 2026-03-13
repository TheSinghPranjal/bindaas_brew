import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared_folder/providers/products_provider.dart';
import 'add_product.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              title: Text(p['name'] as String),
              subtitle: Text('Category: ${p['category']} • Sub: ${p['subcategory']}'),
              trailing: Text('Cal: ${p['calories']}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddProductPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
