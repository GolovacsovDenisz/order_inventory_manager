import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/features/products/products_controller.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        leading: IconButton(
          onPressed: () =>
              ref.read(productsControllerProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<_CreateProductResult>(
                context: context,
                builder: (_) => const _CreateProductDialog(),
              );
              if (result != null && context.mounted) {
                await ref
                    .read(productsControllerProvider.notifier)
                    .addProduct(
                      name: result.name,
                      price: result.price,
                      stock: result.stock,
                      notes: result.notes,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product created')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load products',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(productsControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products yet'))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(productsControllerProvider.notifier).refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                        '\$${p.price.toStringAsFixed(2)} · Stock: ${p.stock}',
                      ),
                      onTap: () async {
                        final result = await showDialog<_EditProductResult>(
                          context: context,
                          builder: (_) => _EditProductDialog(
                            name: p.name,
                            price: p.price,
                            stock: p.stock,
                            notes: p.notes,
                          ),
                        );
                        if (result != null && context.mounted) {
                          await ref
                              .read(productsControllerProvider.notifier)
                              .updateProduct(
                                p.copyWith(
                                  name: result.name,
                                  price: result.price,
                                  stock: result.stock,
                                  notes: result.notes,
                                ),
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product updated')),
                            );
                          }
                        }
                      },
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete product?'),
                            content: Text(
                              'Delete "${p.name}"? This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    ctx,
                                  ).colorScheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await ref
                              .read(productsControllerProvider.notifier)
                              .deleteProduct(p.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product deleted')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _CreateProductResult {
  final String name;
  final double price;
  final int stock;
  final String? notes;
  _CreateProductResult({
    required this.name,
    required this.price,
    required this.stock,
    this.notes,
  });
}

class _EditProductResult {
  final String name;
  final double price;
  final int stock;
  final String? notes;
  _EditProductResult({
    required this.name,
    required this.price,
    required this.stock,
    this.notes,
  });
}

class _CreateProductDialog extends StatefulWidget {
  const _CreateProductDialog();

  @override
  State<_CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<_CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (x == null) return 'Enter a number';
                if (x < 0) return 'Must be >= 0';
                return null;
              },
            ),
            TextFormField(
              controller: _stock,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final x = int.tryParse(v ?? '');
                if (x == null) return 'Enter a number';
                if (x < 0) return 'Must be >= 0';
                return null;
              },
            ),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              _CreateProductResult(
                name: _name.text.trim(),
                price: double.parse(_price.text.replaceAll(',', '.')),
                stock: int.parse(_stock.text),
                notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  final String name;
  final double price;
  final int stock;
  final String? notes;

  const _EditProductDialog({
    required this.name,
    required this.price,
    required this.stock,
    this.notes,
  });

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _price;
  late TextEditingController _stock;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _price = TextEditingController(text: widget.price.toString());
    _stock = TextEditingController(text: widget.stock.toString());
    _notes = TextEditingController(text: widget.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (x == null) return 'Enter a number';
                if (x < 0) return 'Must be >= 0';
                return null;
              },
            ),
            TextFormField(
              controller: _stock,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final x = int.tryParse(v ?? '');
                if (x == null) return 'Enter a number';
                if (x < 0) return 'Must be >= 0';
                return null;
              },
            ),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              _EditProductResult(
                name: _name.text.trim(),
                price: double.parse(_price.text.replaceAll(',', '.')),
                stock: int.parse(_stock.text),
                notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              ),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
