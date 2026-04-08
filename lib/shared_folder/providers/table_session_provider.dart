import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/table_session.dart';
import '../services/firestore_session_sync_service.dart';

class TableSessionState {
  final Session? currentSession;
  final TableModel? currentTable;
  final String? currentPlaceName;
  final String? currentPlaceLocation;
  final Map<String, Session> sessionsById;
  final Map<String, TableModel> tablesByKey;
  final Map<String, List<Map<String, dynamic>>> activeOrdersBySession;
  final bool isLoading;
  final String? error;

  const TableSessionState({
    required this.currentSession,
    required this.currentTable,
    required this.currentPlaceName,
    required this.currentPlaceLocation,
    required this.sessionsById,
    required this.tablesByKey,
    required this.activeOrdersBySession,
    required this.isLoading,
    required this.error,
  });

  factory TableSessionState.initial() => const TableSessionState(
    currentSession: null,
    currentTable: null,
    currentPlaceName: null,
    currentPlaceLocation: null,
    sessionsById: {},
    tablesByKey: {},
    activeOrdersBySession: {},
    isLoading: false,
    error: null,
  );

  TableSessionState copyWith({
    Session? currentSession,
    TableModel? currentTable,
    String? currentPlaceName,
    String? currentPlaceLocation,
    Map<String, Session>? sessionsById,
    Map<String, TableModel>? tablesByKey,
    Map<String, List<Map<String, dynamic>>>? activeOrdersBySession,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TableSessionState(
      currentSession: currentSession ?? this.currentSession,
      currentTable: currentTable ?? this.currentTable,
      currentPlaceName: currentPlaceName ?? this.currentPlaceName,
      currentPlaceLocation: currentPlaceLocation ?? this.currentPlaceLocation,
      sessionsById: sessionsById ?? this.sessionsById,
      tablesByKey: tablesByKey ?? this.tablesByKey,
      activeOrdersBySession:
          activeOrdersBySession ?? this.activeOrdersBySession,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TableSessionNotifier extends StateNotifier<TableSessionState> {
  TableSessionNotifier({this.syncService}) : super(TableSessionState.initial());

  final Uuid _uuid = const Uuid();
  final FirestoreSessionSyncService? syncService;
  StreamSubscription<Session>? _sessionSub;
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSub;

  String _tableKey(String placeId, String tableNumber) =>
      '$placeId::$tableNumber';

  Future<void> startOrJoinSession({
    required RestaurantSessionInitPayload payload,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final key = _tableKey(payload.placeId, payload.tableNumber);
      final table =
          state.tablesByKey[key] ??
          TableModel(
            tableNumber: payload.tableNumber,
            placeId: payload.placeId,
            status: 'empty',
            sessionId: null,
          );

      final sessions = Map<String, Session>.from(state.sessionsById);
      final tables = Map<String, TableModel>.from(state.tablesByKey);
      final orders = Map<String, List<Map<String, dynamic>>>.from(
        state.activeOrdersBySession,
      );

      Session session;
      final tableHasActiveSession =
          table.status == 'occupied' &&
          table.sessionId != null &&
          sessions.containsKey(table.sessionId) &&
          sessions[table.sessionId]!.isActive;

      if (tableHasActiveSession) {
        final existing = sessions[table.sessionId!]!;
        if (!payload.allowMultiUser &&
            existing.users.isNotEmpty &&
            !existing.users.contains(userId)) {
          throw Exception('This table session does not allow multiple users.');
        }

        final joinedUsers = existing.users.contains(userId)
            ? existing.users
            : [...existing.users, userId];
        if (joinedUsers.length > payload.maxUsers) {
          throw Exception('Table is full. Max users: ${payload.maxUsers}.');
        }

        session = existing.copyWith(users: joinedUsers);
        sessions[session.sessionId] = session;
      } else {
        final sessionId =
            (payload.scannedSessionId == null ||
                payload.scannedSessionId == 'auto_generate_or_null')
            ? _uuid.v4()
            : payload.scannedSessionId!;
        session = Session(
          sessionId: sessionId,
          tableNumber: payload.tableNumber,
          placeId: payload.placeId,
          users: [userId],
          isActive: true,
        );
        sessions[session.sessionId] = session;
        tables[key] = table.copyWith(
          status: 'occupied',
          sessionId: session.sessionId,
        );
        orders.putIfAbsent(session.sessionId, () => []);
      }

      state = state.copyWith(
        isLoading: false,
        currentSession: session,
        currentTable:
            tables[key] ??
            table.copyWith(status: 'occupied', sessionId: session.sessionId),
        currentPlaceName: payload.placeName,
        currentPlaceLocation: payload.placeLocation,
        sessionsById: sessions,
        tablesByKey: tables,
        activeOrdersBySession: orders,
      );

      final currentTable =
          tables[key] ??
          table.copyWith(status: 'occupied', sessionId: session.sessionId);
      if (syncService != null) {
        try {
          await syncService!.upsertSession(
            session: session,
            placeName: payload.placeName,
            placeLocation: payload.placeLocation,
          );
          await syncService!.upsertTable(
            table: currentTable,
            placeName: payload.placeName,
          );
          _bindRealtimeSession(session.sessionId);
        } catch (_) {
          // Ignore cloud sync failures so local flow still works offline.
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addOrderItem({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> product,
    int qty = 1,
  }) {
    final allOrders = Map<String, List<Map<String, dynamic>>>.from(
      state.activeOrdersBySession,
    );
    final sessionOrders = List<Map<String, dynamic>>.from(
      allOrders[sessionId] ?? [],
    );
    final idx = sessionOrders.indexWhere((e) => e['name'] == product['name']);

    if (idx >= 0) {
      final current = Map<String, dynamic>.from(sessionOrders[idx]);
      current['qty'] = (current['qty'] as int? ?? 1) + qty;
      current['updatedBy'] = userId;
      sessionOrders[idx] = current;
    } else {
      sessionOrders.add({
        'name': product['name'],
        'price': product['price'] ?? 0,
        'category': product['category'],
        'subcategory': product['subcategory'],
        'qty': qty,
        'addedBy': userId,
      });
    }

    allOrders[sessionId] = sessionOrders;
    state = state.copyWith(activeOrdersBySession: allOrders);

    if (syncService != null) {
      final latest = sessionOrders.firstWhere(
        (e) => e['name'] == product['name'],
      );
      syncService!
          .upsertOrderItem(sessionId: sessionId, orderItem: latest)
          .catchError((_) {});
    }
  }

  void _bindRealtimeSession(String sessionId) {
    _sessionSub?.cancel();
    _ordersSub?.cancel();

    _sessionSub = syncService!.watchSession(sessionId).listen((remoteSession) {
      final sessions = Map<String, Session>.from(state.sessionsById);
      sessions[remoteSession.sessionId] = remoteSession;
      state = state.copyWith(
        sessionsById: sessions,
        currentSession: remoteSession,
      );
    });

    _ordersSub = syncService!.watchOrders(sessionId).listen((remoteOrders) {
      final allOrders = Map<String, List<Map<String, dynamic>>>.from(
        state.activeOrdersBySession,
      );
      allOrders[sessionId] = remoteOrders;
      state = state.copyWith(activeOrdersBySession: allOrders);
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}

final enableRealtimeFirestoreSyncProvider = Provider<bool>((ref) => false);

final firestoreSessionSyncServiceProvider =
    Provider<FirestoreSessionSyncService?>((ref) {
      final enabled = ref.watch(enableRealtimeFirestoreSyncProvider);
      if (!enabled) return null;
      try {
        return FirestoreSessionSyncService(FirebaseFirestore.instance);
      } catch (_) {
        return null;
      }
    });

final tableSessionProvider =
    StateNotifierProvider<TableSessionNotifier, TableSessionState>((ref) {
      return TableSessionNotifier(
        syncService: ref.watch(firestoreSessionSyncServiceProvider),
      );
    });
