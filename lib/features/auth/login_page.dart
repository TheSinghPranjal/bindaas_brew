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
  bool _useRealSignIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    if (_useRealSignIn) {
      // Try real sign-in (provider will still fallback if it fails).
      await ref.read(authProvider.notifier).signIn();
    } else {
      // Use mock sign-in to avoid native Google SDK crashes in dev.
      await ref.read(authProvider.notifier).signInMock();
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.12),
              colorScheme.primaryContainer.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _loading
                ? const CircularProgressIndicator()
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, color: colorScheme.primary, size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  'Bindaas Brew',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to manage your restaurant experience.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                            ),
                            const SizedBox(height: 24),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                title: const Text('Use real Google sign-in'),
                                subtitle: const Text('Turn off to use safe mock login in dev'),
                                value: _useRealSignIn,
                                onChanged: (v) => setState(() => _useRealSignIn = v),
                                secondary: Icon(
                                  _useRealSignIn ? Icons.toggle_on : Icons.toggle_off_outlined,
                                  color: colorScheme.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                icon: Image.asset(
                                  'assets/icons/google.png',
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.login),
                                ),
                                label: Text(
                                  'Continue with Google${_useRealSignIn ? '' : ' (mock)'}',
                                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                onPressed: _handleGoogleSignIn,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'By continuing, you agree to our terms & privacy policy.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
