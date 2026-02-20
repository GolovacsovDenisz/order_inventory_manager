import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/core/widgets/snackbars.dart';
import 'package:order_inventory_manager/core/widgets/empty_state.dart';
import 'package:order_inventory_manager/features/orders/data/orders_prefs.dart';
import 'package:order_inventory_manager/features/orders/domain/order.dart';
import 'package:order_inventory_manager/features/orders/domain/order_status.dart';
import 'package:order_inventory_manager/features/orders/orders_controller.dart';

enum _OrderSortField { date, total, status }

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {};
  bool _isSearchVisible = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  OrderStatus? _filterStatus;
  _OrderSortField _sortField = _OrderSortField.date;
  bool _sortAscending = true;

  void _enterSelectionMode(String orderId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds = {orderId};
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds = {};
    });
  }

  void _toggleSelection(String orderId) {
    setState(() {
      if (_selectedIds.contains(orderId)) {
        _selectedIds = {..._selectedIds..remove(orderId)};
      } else {
        _selectedIds = {..._selectedIds, orderId};
      }
    });
  }

  void _selectAll(List<Order> orders) {
    setState(() {
      _selectedIds = orders.map((o) => o.id).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadOrdersPrefs();
  }

  /// Load last saved filter/sort from disk and apply to state.
  Future<void> _loadOrdersPrefs() async {
    final prefs = await loadOrdersPrefs();
    if (!mounted) return;
    setState(() {
      _filterStatus = prefs.filterStatus;
      _sortField = _sortFieldFromString(prefs.sortField);
      _sortAscending = prefs.sortAscending;
    });
  }

  static _OrderSortField _sortFieldFromString(String s) {
    switch (s) {
      case 'total':
        return _OrderSortField.total;
      case 'status':
        return _OrderSortField.status;
      default:
        return _OrderSortField.date;
    }
  }

  /// Persist current filter/sort so they restore on next open.
  void _saveOrdersPrefs({
    OrderStatus? filterStatus,
    String? sortField,
    bool? sortAscending,
  }) {
    saveOrdersPrefs(
      filterStatus: filterStatus ?? _filterStatus,
      sortField: sortField ?? _sortField.name,
      sortAscending: sortAscending ?? _sortAscending,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Widget> _sortTiles(
    BuildContext ctx,
    String label,
    _OrderSortField field,
    IconData iconData,
  ) {
    final groupValue = '${_sortField.name}_${_sortAscending ? "asc" : "desc"}';
    return [
      ListTile(
        leading: Icon(iconData, size: 20),
        title: Text('$label ↑'),
        trailing: groupValue == '${field.name}_asc'
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () {
          setState(() {
            _sortField = field;
            _sortAscending = true;
          });
          _saveOrdersPrefs(sortField: field.name, sortAscending: true);
          Navigator.pop(ctx);
        },
      ),
      ListTile(
        leading: Icon(iconData, size: 20),
        title: Text('$label ↓'),
        trailing: groupValue == '${field.name}_desc'
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () {
          setState(() {
            _sortField = field;
            _sortAscending = false;
          });
          _saveOrdersPrefs(sortField: field.name, sortAscending: false);
          Navigator.pop(ctx);
        },
      ),
    ];
  }

  Future<void> _deleteSelected(List<Order> orders) async {
    final toDelete = orders.where((o) => _selectedIds.contains(o.id)).toList();
    if (toDelete.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete orders?'),
        content: Text(
          'Delete ${toDelete.length} order(s)? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final controller = ref.read(ordersControllerProvider.notifier);
    for (final o in toDelete) {
      await controller.deleteOrder(o.id);
    }
    if (mounted) {
      _exitSelectionMode();
      final state = ref.read(ordersControllerProvider);
      if (state.hasError) {
        showErrorSnackBar(context, 'Operation failed');
      } else {
        showSuccessSnackBar(context, '${toDelete.length} order(s) deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersControllerProvider);

    String formatMoney(double value) {
      return '\$${value.toStringAsFixed(2)}';
    }

    String formatDate(DateTime dt) {
      final d = dt.toLocal();
      String two(int x) => x.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    }

    final ordersList = ordersAsync.maybeWhen(
      data: (orders) => orders,
      orElse: () => <Order>[],
    );

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              title: Text('${_selectedIds.length} selected'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel',
                onPressed: _exitSelectionMode,
              ),
              actions: [
                TextButton(
                  onPressed: ordersList.isEmpty
                      ? null
                      : () => _selectAll(ordersList),
                  child: const Text('Select all'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _deleteSelected(ordersList),
                ),
              ],
            )
          : AppBar(
              title: _isSearchVisible
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search by title or notes',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    )
                  : const Center(child: Text('Orders')),
              leading: _isSearchVisible
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close search',
                      onPressed: () => setState(() {
                        _isSearchVisible = false;
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    )
                  : IconButton(
                      tooltip: 'Refresh',
                      onPressed: () =>
                          ref.read(ordersControllerProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                    ),
              actions: [
                if (_isSearchVisible)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter by status',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Filter by status',
                                  style: Theme.of(ctx).textTheme.titleMedium,
                                ),
                              ),
                              ListTile(
                                title: const Text('All'),
                                leading: Radio<OrderStatus?>(
                                  value: null,
                                  groupValue: _filterStatus,
                                  onChanged: (v) {
                                    setState(() => _filterStatus = null);
                                    _saveOrdersPrefs(filterStatus: null);
                                    Navigator.pop(ctx);
                                  },
                                ),
                                onTap: () {
                                  setState(() => _filterStatus = null);
                                  _saveOrdersPrefs(filterStatus: null);
                                  Navigator.pop(ctx);
                                },
                              ),
                              ...OrderStatus.values.map(
                                (status) => ListTile(
                                  title: Text(status.label),
                                  leading: Radio<OrderStatus?>(
                                    value: status,
                                    groupValue: _filterStatus,
                                    onChanged: (v) {
                                      setState(() => _filterStatus = status);
                                      _saveOrdersPrefs(filterStatus: status);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                  onTap: () {
                                    setState(() => _filterStatus = status);
                                    _saveOrdersPrefs(filterStatus: status);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    tooltip: 'Sort',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Sort by',
                                  style: Theme.of(ctx).textTheme.titleMedium,
                                ),
                              ),
                              ..._sortTiles(ctx, 'Date', _OrderSortField.date, Icons.calendar_today),
                              ..._sortTiles(ctx, 'Total', _OrderSortField.total, Icons.attach_money),
                              ..._sortTiles(ctx, 'Status', _OrderSortField.status, Icons.label),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                    onPressed: () => setState(() => _isSearchVisible = true),
                  ),
                  IconButton(
                    tooltip: 'add',
                    onPressed: () async {
                      final result = await showDialog<_CreateOrderResult>(
                        context: context,
                        builder: (d) => _CreateOrderDialog(),
                      );
                      if (result != null && context.mounted) {
                        await ref
                            .read(ordersControllerProvider.notifier)
                            .addOrder(
                              title: result.title,
                              total: result.total,
                              notes: result.notes,
                            );
                        if (context.mounted) {
                          final state = ref.read(ordersControllerProvider);
                          if (state.hasError) {
                            showErrorSnackBar(context, 'Operation failed');
                          } else {
                            showSuccessSnackBar(context, 'Order created');
                          }
                        }
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ],
            ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Failed to load orders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(ordersControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          final query = _searchQuery.trim().toLowerCase();
          final filtered = query.isEmpty
              ? orders
              : orders.where((o) {
                  final matchTitle =
                      o.title.toLowerCase().contains(query);
                  final matchNotes = o.notes != null &&
                      o.notes!.toLowerCase().contains(query);
                  return matchTitle || matchNotes;
                }).toList();

          final statusFiltered = _filterStatus == null
              ? filtered
              : filtered.where((o) => o.status == _filterStatus).toList();

          if (orders.isEmpty) {
            return const EmptyState(icon: Icons.shopping_bag, message: 'No orders yet');
          }
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              message: 'No orders match "$query"',
            );
          }
          if (statusFiltered.isEmpty) {
            return EmptyState(
              icon: Icons.filter_list_off,
              message: 'No orders with status "${_filterStatus!.label}"',
            );
          }

          final sorted = List<Order>.from(statusFiltered);
          sorted.sort((a, b) {
            int cmp;
            switch (_sortField) {
              case _OrderSortField.date:
                cmp = a.createdAt.compareTo(b.createdAt);
                break;
              case _OrderSortField.total:
                cmp = a.total.compareTo(b.total);
                break;
              case _OrderSortField.status:
                cmp = a.status.index.compareTo(b.status.index);
                break;
            }
            return _sortAscending ? cmp : -cmp;
          });

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(ordersControllerProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (BuildContext context, _) =>
                  const Divider(height: 1),
              itemBuilder: (context, i) {
                final o = sorted[i];

                return ListTile(
                  leading: _isSelectionMode
                      ? Checkbox(
                          value: _selectedIds.contains(o.id),
                          onChanged: (v) => _toggleSelection(o.id),
                        )
                      : CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.receipt_long,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                  onLongPress: _isSelectionMode
                      ? null
                      : () => _enterSelectionMode(o.id),
                  onTap: _isSelectionMode
                      ? () => _toggleSelection(o.id)
                      : () async {
                          final result = await showDialog<_EditOrderResult>(
                            context: context,
                            builder: (d) => _EditOrderDialog(
                              title: o.title,
                              total: o.total,
                              notes: o.notes,
                            ),
                          );
                          if (result != null && context.mounted) {
                            await ref
                                .read(ordersControllerProvider.notifier)
                                .updateOrder(
                                  o.copyWith(
                                    title: result.title,
                                    total: result.total,
                                    notes: result.notes,
                                  ),
                                );
                            if (context.mounted) {
                              final state = ref.read(ordersControllerProvider);
                              if (state.hasError) {
                                showErrorSnackBar(context, 'Operation failed');
                              } else {
                                showSuccessSnackBar(context, 'Order updated');
                              }
                            }
                          }
                        },
                  title: Text(
                    o.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          PopupMenuButton<OrderStatus>(
                            itemBuilder: (context) => OrderStatus.values
                                .map(
                                  (status) => PopupMenuItem<OrderStatus>(
                                    value: status,
                                    child: Text(status.label),
                                  ),
                                )
                                .toList(),
                            onSelected: (OrderStatus? newStatus) async {
                              if (newStatus == null) return;
                              await ref.read(ordersControllerProvider.notifier).updateOrder(
                                o.copyWith(status: newStatus),
                              );
                              if (context.mounted) {
                                final state = ref.read(ordersControllerProvider);
                                if (state.hasError) {
                                  showErrorSnackBar(context, 'Operation failed');
                                } else {
                                  showSuccessSnackBar(context, 'Status updated');
                                }
                              }
                            },
                            child: _StatusChip(o.status),
                          ),
                          Text(
                            '${formatDate(o.createdAt)} · ${formatMoney(o.total)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CreateOrderResult {
  final String title;
  final double total;
  final String? notes;
  _CreateOrderResult({required this.title, required this.total, this.notes});
}

class _EditOrderResult {
  final String title;
  final double total;
  final String? notes;
  _EditOrderResult({required this.title, required this.total, this.notes});
}

class _CreateOrderDialog extends StatefulWidget {
  const _CreateOrderDialog();

  @override
  State<_CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _EditOrderDialog extends StatefulWidget {
  final String title;
  final double total;
  final String? notes;

  const _EditOrderDialog({
    required this.title,
    required this.total,
    required this.notes,
  });

  @override
  State<_EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<_EditOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _total;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.title);
    _total = TextEditingController(text: widget.total.toString());
    _notes = TextEditingController(text: widget.notes ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _total.dispose();
    _notes.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant)
          : null,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Edit order'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: _inputDecoration('Title', icon: Icons.receipt_long),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _total,
                decoration: _inputDecoration('Total', icon: Icons.attach_money),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (x == null) return 'Enter a number';
                  if (x < 0) return 'Must be >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration: _inputDecoration('Notes (optional)', icon: Icons.note_outlined),
                textInputAction: TextInputAction.done,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
              _EditOrderResult(
                title: _title.text.trim(),
                total: double.parse(_total.text.replaceAll(',', '.')),
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

class _CreateOrderDialogState extends State<_CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _total = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _total.dispose();
    _notes.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant)
          : null,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Create order'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: _inputDecoration('Title', icon: Icons.receipt_long),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _total,
                decoration: _inputDecoration('Total', icon: Icons.attach_money),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (x == null) return 'Enter a number';
                  if (x < 0) return 'Must be >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration: _inputDecoration('Notes (optional)', icon: Icons.note_outlined),
                textInputAction: TextInputAction.done,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
              _CreateOrderResult(
                title: _title.text.trim(),
                total: double.parse(_total.text.replaceAll(',', '.')),
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

Color _colorForStatus(OrderStatus status) {
  return switch (status) {
    OrderStatus.newOrder => Colors.green,
    OrderStatus.inProgress => Colors.orange,
    OrderStatus.done => Colors.blue,
    OrderStatus.cancelled => Colors.red,
  };
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: _colorForStatus(status),
      label: Text(status.label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
