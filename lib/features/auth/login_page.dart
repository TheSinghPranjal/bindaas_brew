import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mode_choice.dart';
import '../../shared_folder/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).signIn();
    setState(() => _loading = false);

    final acct = ref.read(authProvider);
    if (acct != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ModeChoice()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: Image.asset('assets/icons/google.png', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.login)),
                label: const Text('Sign in with Google'),
                onPressed: _handleGoogleSignIn,
              ),
      ),
    );
  }
}
