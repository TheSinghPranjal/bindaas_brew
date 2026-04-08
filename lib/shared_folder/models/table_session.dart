class Session {
  final String sessionId;
  final String tableNumber;
  final String placeId;
  final List<String> users;
  final bool isActive;

  const Session({
    required this.sessionId,
    required this.tableNumber,
    required this.placeId,
    required this.users,
    required this.isActive,
  });

  Session copyWith({List<String>? users, bool? isActive}) {
    return Session(
      sessionId: sessionId,
      tableNumber: tableNumber,
      placeId: placeId,
      users: users ?? this.users,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TableModel {
  final String tableNumber;
  final String placeId;
  final String status; // empty | occupied
  final String? sessionId;

  const TableModel({
    required this.tableNumber,
    required this.placeId,
    required this.status,
    this.sessionId,
  });

  TableModel copyWith({String? status, String? sessionId}) {
    return TableModel(
      tableNumber: tableNumber,
      placeId: placeId,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class RestaurantSessionInitPayload {
  final String type;
  final String placeName;
  final String placeId;
  final String? placeLocation;
  final String tableNumber;
  final int? capacity;
  final String? zone;
  final String? scannedSessionId;
  final bool allowMultiUser;
  final int maxUsers;
  final bool menuAccess;
  final bool placeOrder;
  final String initialScreen;
  final String fallbackScreen;
  final String qrVersion;
  final String? timestamp;

  const RestaurantSessionInitPayload({
    required this.type,
    required this.placeName,
    required this.placeId,
    required this.placeLocation,
    required this.tableNumber,
    required this.capacity,
    required this.zone,
    required this.scannedSessionId,
    required this.allowMultiUser,
    required this.maxUsers,
    required this.menuAccess,
    required this.placeOrder,
    required this.initialScreen,
    required this.fallbackScreen,
    required this.qrVersion,
    required this.timestamp,
  });

  factory RestaurantSessionInitPayload.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    if (type != 'restaurant_session_init') {
      throw const FormatException('Unsupported QR type');
    }

    final place = json['place'] as Map<String, dynamic>?;
    final table = json['table'] as Map<String, dynamic>?;
    final session = json['session'] as Map<String, dynamic>?;
    final features = json['features'] as Map<String, dynamic>?;
    final navigation = json['navigation'] as Map<String, dynamic>?;
    final meta = json['meta'] as Map<String, dynamic>?;

    if (place == null || table == null || session == null) {
      throw const FormatException('Invalid QR payload fields');
    }

    final placeName = place['name']?.toString();
    final placeId = place['placeId']?.toString();
    final tableNumber = table['tableNumber']?.toString();

    if (placeName == null || placeName.isEmpty) {
      throw const FormatException('Missing place name in QR');
    }
    if (placeId == null || placeId.isEmpty) {
      throw const FormatException('Missing placeId in QR');
    }
    if (tableNumber == null || tableNumber.isEmpty) {
      throw const FormatException('Missing table number in QR');
    }

    return RestaurantSessionInitPayload(
      type: type,
      placeName: placeName,
      placeId: placeId,
      placeLocation: place['location']?.toString(),
      tableNumber: tableNumber,
      capacity: int.tryParse(table['capacity']?.toString() ?? ''),
      zone: table['zone']?.toString(),
      scannedSessionId: session['sessionId']?.toString(),
      allowMultiUser: session['allowMultiUser'] == true,
      maxUsers: int.tryParse(session['maxUsers']?.toString() ?? '') ?? 4,
      menuAccess: features == null ? true : features['menuAccess'] != false,
      placeOrder: features == null ? true : features['placeOrder'] != false,
      initialScreen: navigation?['initialScreen']?.toString() ?? 'MenuScreen',
      fallbackScreen: navigation?['fallbackScreen']?.toString() ?? 'HomeScreen',
      qrVersion: meta?['qrVersion']?.toString() ?? '1.0',
      timestamp: meta?['timestamp']?.toString(),
    );
  }
}
