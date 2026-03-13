import 'dart:convert';
import 'role.dart';

class User {
  String employeeId;
  String name;
  String username;
  String mobile;
  String? alternateMobile;
  String email;
  String designation;
  List<String> roles;
  String? photo;
  String? about;
  int? age;
  List<String>? languages;
  String? joiningDate;
  String? status;
  String? address;
  String? emergencyContact;

  User({
    required this.employeeId,
    required this.name,
    required this.username,
    required this.mobile,
    this.alternateMobile,
    required this.email,
    required this.designation,
  required this.roles,
    this.photo,
    this.about,
    this.age,
    this.languages,
    this.joiningDate,
    this.status,
    this.address,
    this.emergencyContact,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      employeeId: json['employeeId'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      mobile: json['mobile'] ?? '',
      alternateMobile: json['alternateMobile'],
      email: json['email'] ?? '',
      designation: json['designation'] ?? '',
    roles: json['roles'] != null
      ? List<String>.from(json['roles'])
      : (json['role'] != null ? [json['role']] : []),
      photo: json['photo'],
      about: json['about'],
      age: json['age'] is int ? json['age'] : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      languages: json['languages'] != null ? List<String>.from(json['languages']) : null,
      joiningDate: json['joiningDate'],
      status: json['status'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'username': username,
      'mobile': mobile,
      'alternateMobile': alternateMobile,
      'email': email,
      'designation': designation,
  'roles': roles,
      'photo': photo,
      'about': about,
      'age': age,
      'languages': languages,
      'joiningDate': joiningDate,
      'status': status,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }

  @override
  String toString() => jsonEncode(toJson());

  List<Role> get rolesEnum => roles.map((r) => roleFromString(r)).whereType<Role>().toList();
}
