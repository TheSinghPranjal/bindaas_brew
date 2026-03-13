import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared_folder/providers/products_provider.dart';
import '../../shared_folder/providers/categories_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _assignedChef;
  bool _available = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _calCtrl.dispose();
    _priceCtrl.dispose();
    _prepCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final product = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'calories': int.tryParse(_calCtrl.text) ?? 0,
      'chef': _assignedChef ?? '',
      'category': _selectedCategory ?? 'Unassigned',
      'subcategory': _selectedSubcategory ?? '',
      'price': double.tryParse(_priceCtrl.text) ?? 0.0,
      'prepTime': _prepCtrl.text,
      'available': _available,
    };

    ref.read(productsProvider.notifier).addProduct(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final categoryNames = categories.map((c) => c['name'] as String).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextFormField(controller: _calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories')),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select Category')),
                  ...categoryNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList()
                ],
                onChanged: (v) => setState(() {
                  _selectedCategory = v;
                  _selectedSubcategory = null;
                }),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => (v == null) ? 'Select a category' : null,
              ),
              // Subcategory selection
              if (_selectedCategory != null)
                DropdownButtonFormField<String>(
                  value: _selectedSubcategory,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Select Subcategory')),
                    ...categories.firstWhere((c) => c['name'] == _selectedCategory)['subcategories'].map<DropdownMenuItem<String>>((s) => DropdownMenuItem(value: s as String, child: Text(s as String))).toList()
                  ],
                  onChanged: (v) => setState(() => _selectedSubcategory = v),
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                ),
              TextFormField(controller: _priceCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price')),
              TextFormField(controller: _prepCtrl, decoration: const InputDecoration(labelText: 'Preparation Time')),
              TextFormField(controller: TextEditingController(), decoration: const InputDecoration(labelText: 'Assigned Chef')),
              SwitchListTile(title: const Text('Available'), value: _available, onChanged: (v) => setState(() => _available = v)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _submit, child: const Text('Add Product')),
            ],
          ),
        ),
      ),
    );
  }
}
