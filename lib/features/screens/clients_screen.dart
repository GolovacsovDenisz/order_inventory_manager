import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/core/widgets/snackbars.dart';
import 'package:order_inventory_manager/core/widgets/empty_state.dart';
import 'package:order_inventory_manager/features/clients/clients_controller.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        leading: IconButton(
          onPressed: () =>
              ref.read(clientsControllerProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<_CreateClientResult>(
                context: context,
                builder: (_) => const _CreateClientDialog(),
              );
              if (result != null && context.mounted) {
                await ref.read(clientsControllerProvider.notifier).addClient(
                      name: result.name,
                      phone: result.phone,
                      notes: result.notes,
                      email: result.email,
                    );
                if (context.mounted) {
                  final state = ref.read(clientsControllerProvider);
                  if (state.hasError) {
                    showErrorSnackBar(context, 'Operation failed');
                  } else {
                    showSuccessSnackBar(context, 'Client created');
                  }
                }
              }
            },
          ),
        ],
      ),
      body: clientsAsync.when(
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
                  'Failed to load clients',
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
                      ref.read(clientsControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (clients) => clients.isEmpty
            ? const EmptyState(icon: Icons.people_alt, message: 'No clients yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(clientsControllerProvider.notifier).refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = clients[index];
                    final theme = Theme.of(context);
                    final initial = c.name.isNotEmpty
                        ? c.name.trim().substring(0, 1).toUpperCase()
                        : '?';
                    final contactParts = [c.phone, c.email]
                        .where((s) => s != null && s.isNotEmpty)
                        .cast<String>()
                        .toList();
                    final contact = contactParts.isEmpty
                        ? 'No contact'
                        : contactParts.join(' · ');
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          initial,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          contact,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onTap: () async {
                        final result = await showDialog<_EditClientResult>(
                          context: context,
                          builder: (_) => _EditClientDialog(
                            name: c.name,
                            phone: c.phone,
                            notes: c.notes,
                            email: c.email,
                          ),
                        );
                        if (result != null && context.mounted) {
                          await ref
                              .read(clientsControllerProvider.notifier)
                              .updateClient(
                                c.copyWith(
                                  name: result.name,
                                  phone: result.phone,
                                  notes: result.notes,
                                  email: result.email,
                                ),
                              );
                          if (context.mounted) {
                            final state = ref.read(clientsControllerProvider);
                            if (state.hasError) {
                              showErrorSnackBar(context, 'Operation failed');
                            } else {
                              showSuccessSnackBar(context, 'Client updated');
                            }
                          }
                        }
                      },
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete client?'),
                            content: Text(
                              'Delete "${c.name}"? This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(ctx).colorScheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await ref
                              .read(clientsControllerProvider.notifier)
                              .deleteClient(c.id);
                          if (context.mounted) {
                            final state = ref.read(clientsControllerProvider);
                            if (state.hasError) {
                              showErrorSnackBar(context, 'Operation failed');
                            } else {
                              showSuccessSnackBar(context, 'Client deleted');
                            }
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

class _CreateClientResult {
  final String name;
  final String? phone;
  final String? notes;
  final String? email;
  _CreateClientResult({
    required this.name,
    this.phone,
    this.notes,
    this.email,
  });
}

class _EditClientResult {
  final String name;
  final String? phone;
  final String? notes;
  final String? email;
  _EditClientResult({
    required this.name,
    this.phone,
    this.notes,
    this.email,
  });
}

class _CreateClientDialog extends StatefulWidget {
  const _CreateClientDialog();

  @override
  State<_CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends State<_CreateClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    _email.dispose();
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
      title: const Text('Create client'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: _inputDecoration('Name', icon: Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                decoration: _inputDecoration('Phone (optional)', icon: Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: _inputDecoration('Email (optional)', icon: Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
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
              _CreateClientResult(
                name: _name.text.trim(),
                phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _EditClientDialog extends StatefulWidget {
  final String name;
  final String? phone;
  final String? notes;
  final String? email;

  const _EditClientDialog({
    required this.name,
    this.phone,
    this.notes,
    this.email,
  });

  @override
  State<_EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<_EditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _notes;
  late TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _phone = TextEditingController(text: widget.phone ?? '');
    _notes = TextEditingController(text: widget.notes ?? '');
    _email = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    _email.dispose();
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
      title: const Text('Edit client'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: _inputDecoration('Name', icon: Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                decoration: _inputDecoration('Phone (optional)', icon: Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: _inputDecoration('Email (optional)', icon: Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
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
              _EditClientResult(
                name: _name.text.trim(),
                phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              ),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
