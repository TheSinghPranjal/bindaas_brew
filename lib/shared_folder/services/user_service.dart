import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user.dart';

class UserService {
  /// Loads mock users from assets/data/users.json
  static Future<List<User>> loadMockUsers() async {
    final jsonStr = await rootBundle.loadString('assets/data/users.json');
    final list = json.decode(jsonStr) as List<dynamic>;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }
}
