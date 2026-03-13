import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CategoriesNotifier()
      : super([
          {'name': 'Food', 'subcategories': ['South Indian', 'North Indian', 'Chinese'], 'veg': true},
          {'name': 'Beverages', 'subcategories': ['Tea', 'Coffee', 'Juice'], 'veg': true},
        ]);

  void addCategory(Map<String, dynamic> category) {
    state = [...state, category];
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Map<String, dynamic>>>((ref) {
  return CategoriesNotifier();
});
