import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared_folder/providers/categories_provider.dart';

class AddCategoryPage extends ConsumerStatefulWidget {
  const AddCategoryPage({super.key});

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _subCtrl = TextEditingController();
  bool _veg = true;
  bool _mocktail = false;
  bool _cocktail = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final subs = _subCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final category = {
      'name': name,
      'subcategories': subs,
      'veg': _veg,
      'mocktail': _mocktail,
      'cocktail': _cocktail,
    };
    ref.read(categoriesProvider.notifier).addCategory(category);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _subCtrl,
                decoration: const InputDecoration(labelText: 'Subcategories (comma separated)'),
              ),
              SwitchListTile(title: const Text('Veg'), value: _veg, onChanged: (v) => setState(() => _veg = v)),
              SwitchListTile(title: const Text('Mocktail'), value: _mocktail, onChanged: (v) => setState(() => _mocktail = v)),
              SwitchListTile(title: const Text('Cocktail'), value: _cocktail, onChanged: (v) => setState(() => _cocktail = v)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _submit, child: const Text('Add Category')),
            ],
          ),
        ),
      ),
    );
  }
}
