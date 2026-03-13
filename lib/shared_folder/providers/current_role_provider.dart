import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'users_provider.dart';
import '../models/role.dart';

/// Derives the current user's Roles by matching the signed-in auth email to a User record.
final currentRolesProvider = Provider<List<Role>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final users = ref.watch(usersProvider);
  final matches = users.where((u) => u.email.toLowerCase() == auth.email.toLowerCase());
  if (matches.isEmpty) return [];
  return matches.first.rolesEnum;
});

