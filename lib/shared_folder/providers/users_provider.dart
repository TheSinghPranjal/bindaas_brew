import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UsersNotifier extends StateNotifier<List<User>> {
  UsersNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    final users = await UserService.loadMockUsers();
    state = users;
  }

  /// Adds a role to the user's roles list (in-memory). Avoids duplicates.
  void addRole(String employeeId, String role) {
    final idx = state.indexWhere((u) => u.employeeId == employeeId);
    if (idx == -1) return;
    final roles = List<String>.from(state[idx].roles);
    if (!roles.contains(role)) {
      roles.add(role);
      state[idx].roles = roles;
      state = [...state];
    }
  }

  /// Replace the user's roles with the provided list.
  void setRoles(String employeeId, List<String> roles) {
    final idx = state.indexWhere((u) => u.employeeId == employeeId);
    if (idx == -1) return;
    state[idx].roles = List<String>.from(roles);
    state = [...state];
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, List<User>>((ref) {
  return UsersNotifier();
});
