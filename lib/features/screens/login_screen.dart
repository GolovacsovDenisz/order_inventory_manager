import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/features/auth/data/firebase_auth_provider.dart';
import 'package:order_inventory_manager/features/auth/ui/auth_error_messages.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  bool _obscure = true;

  final _formkey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final vEmail = value?.trim() ?? '';
    if (vEmail.isEmpty) return 'email is required';
    if (!vEmail.contains('@') || !vEmail.contains('.')) {
      return 'Enter a valid Email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final vPassword = value?.trim() ?? '';
    if (vPassword.isEmpty) return 'password is required';
    if (vPassword.length < 6) return 'minimum 6 chatacters';
    return null;
  }

  Future<void> _submit(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();

    final valid = _formkey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _loading = true);
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      final msg = authErrorMessage(error);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(firebaseAuthProvider);

    return Scaffold(
      appBar: AppBar(title: Text('login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //emaial
              TextFormField(
                controller: _email,
                autocorrect: false, 
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _validateEmail,
                textInputAction: TextInputAction.next,
                enabled: !_loading,
              ),
              SizedBox(height: 12),
              //password
              TextFormField(
                controller: _password,
                autocorrect: false,
                autofillHints: [AutofillHints.password],
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: _validatePassword,
                enabled: !_loading,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => _submit(() async {
                  await auth.signInWithEmailAndPassword(
                    email: _email.text.trim(),
                    password: _password.text,
                  );
                }),
              ),
              SizedBox(height: 20),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () => _submit(() async {
                        await auth.signInWithEmailAndPassword(
                          email: _email.text.trim(),
                          password: _password.text,
                        );
                      }),
                child: _loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(),
                      )
                    : Text('sign in'),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loading
                    ? null
                    : () => _submit(() async {
                        await auth.createUserWithEmailAndPassword(
                          email: _email.text.trim(),
                          password: _password.text, 
                        );
                      }),
                child: Text('Create account', style: TextStyle(color: Colors.blue),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
