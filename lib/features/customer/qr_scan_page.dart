import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../shared_folder/providers/auth_provider.dart';
import '../../shared_folder/providers/table_session_provider.dart';
import '../../shared_folder/models/table_session.dart';
import 'restaurant_menu_screen.dart';

class QrScanPage extends ConsumerStatefulWidget {
  const QrScanPage({super.key});

  @override
  ConsumerState<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends ConsumerState<QrScanPage> {
  bool _processing = false;
  final TextEditingController _jsonController = TextEditingController();

  Future<void> _handleRawQr(String rawValue) async {
    if (_processing) return;
    setState(() => _processing = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('QR must be a JSON object');
      }
      final payload = RestaurantSessionInitPayload.fromJson(decoded);
      final user = ref.read(authProvider);
      final userId = user?.email ?? 'guest@local';

      await ref
          .read(tableSessionProvider.notifier)
          .startOrJoinSession(payload: payload, userId: userId);

      final sessionState = ref.read(tableSessionProvider);
      if (sessionState.error != null) {
        throw Exception(sessionState.error);
      }

      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const RestaurantMenuScreen()),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Invalid/unsupported QR: $e')),
      );
      setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _openManualJsonDialog() async {
    _jsonController.text = '''
{
  "type": "restaurant_session_init",
  "place": {"name": "Spice Garden", "placeId": "REST12345", "location": "Bangalore, India"},
  "table": {"tableNumber": 12, "capacity": 4, "zone": "Indoor"},
  "session": {"sessionId": "auto_generate_or_null", "allowMultiUser": true, "maxUsers": 4},
  "features": {"menuAccess": true, "placeOrder": true, "splitBill": true, "callWaiter": true, "liveOrderTracking": true, "tips": true, "ratings": true},
  "navigation": {"initialScreen": "MenuScreen", "fallbackScreen": "HomeScreen"},
  "meta": {"qrVersion": "1.0", "timestamp": "2026-03-24T10:00:00Z"}
}
''';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Paste QR JSON'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: _jsonController,
            minLines: 8,
            maxLines: 14,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste QR JSON payload',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _handleRawQr(_jsonController.text);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tableSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Table QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final raw = capture.barcodes.first.rawValue;
              if (raw == null || raw.isEmpty) return;
              _handleRawQr(raw);
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Point camera at table QR',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (state.isLoading || _processing)
                      const LinearProgressIndicator(),
                    if (state.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openManualJsonDialog,
        icon: const Icon(Icons.paste_rounded),
        label: const Text('Paste QR JSON'),
      ),
    );
  }
}
