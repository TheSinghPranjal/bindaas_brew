import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared_folder/providers/auth_provider.dart';
import '../../shared_folder/providers/categories_provider.dart';
import '../../shared_folder/providers/products_provider.dart';
import '../../shared_folder/providers/table_session_provider.dart';

class RestaurantMenuScreen extends ConsumerStatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  ConsumerState<RestaurantMenuScreen> createState() =>
      _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends ConsumerState<RestaurantMenuScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(tableSessionProvider);
    final session = sessionState.currentSession;
    if (session == null) {
      return const Scaffold(
        body: Center(
          child: Text('No active session found. Please scan QR again.'),
        ),
      );
    }

    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final userId = ref.watch(authProvider)?.email ?? 'guest@local';
    final activeOrders =
        sessionState.activeOrdersBySession[session.sessionId] ?? const [];

    final selectedCategory =
        _selectedCategory ??
        (categories.isNotEmpty ? categories.first['name']?.toString() : null);
    final filteredProducts = selectedCategory == null
        ? products
        : products
              .where((p) => p['category']?.toString() == selectedCategory)
              .toList();

    final total = activeOrders.fold<num>(
      0,
      (sum, item) =>
          sum + ((item['price'] as num? ?? 0) * (item['qty'] as int? ?? 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sessionState.currentPlaceName ?? 'Restaurant Menu'),
            Text(
              'Table ${session.tableNumber} · Session ${session.sessionId.substring(0, 8)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Joined users (${session.users.length})'),
                const SizedBox(height: 4),
                Text(
                  session.users.join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: categories.map((c) {
                final name = c['name']?.toString() ?? 'Category';
                final selected = selectedCategory == name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = name),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                final price = p['price'] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(p['name']?.toString() ?? 'Item'),
                    subtitle: Text(
                      '${p['description'] ?? ''}\n${p['subcategory'] ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: FilledButton(
                      onPressed: () {
                        ref
                            .read(tableSessionProvider.notifier)
                            .addOrderItem(
                              sessionId: session.sessionId,
                              userId: userId,
                              product: p,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${p['name']} added to shared cart'),
                          ),
                        );
                      },
                      child: Text('Rs $price'),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shared cart (${activeOrders.length} items)'),
                const SizedBox(height: 6),
                if (activeOrders.isEmpty)
                  const Text('No items yet. Add items from menu.')
                else
                  ...activeOrders
                      .take(3)
                      .map(
                        (item) => Text(
                          '${item['name']} x${item['qty']}  (Rs ${(item['price'] as num? ?? 0) * (item['qty'] as int? ?? 1)})',
                        ),
                      ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: Rs $total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
