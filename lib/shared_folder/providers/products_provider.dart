import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

class ProductsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ProductsNotifier()
      : super([
          {
            'name': 'Masala Dosa',
            'description': 'Crispy dosa with masala',
            'calories': 250,
            'chef': 'Priya',
            'category': 'Food',
            'subcategory': 'South Indian',
            'price': 80,
            'prepTime': '15m',
            'available': true
          }
        ]);

  void addProduct(Map<String, dynamic> product) {
    state = [...state, product];
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Map<String, dynamic>>>((ref) {
  return ProductsNotifier();
});
