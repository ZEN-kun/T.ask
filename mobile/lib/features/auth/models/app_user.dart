class AppUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'manager' | 'employee'
  final String? photoUrl;
  
  // Manager-specific fields
  final String? companyName;
  final String? sector;

  // Employee-specific fields
  final int? age;
  final String? department;
  final String? managerId;
  final String? managerName;

  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.companyName,
    this.sector,
    this.age,
    this.department,
    this.managerId,
    this.managerName,
    required this.createdAt,
  });

  bool get isManager => role == 'manager';
  bool get isEmployee => role == 'employee';

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'employee',
      photoUrl: data['photo_url'] ?? data['photoUrl'],
      companyName: data['company_name'],
      sector: data['sector'],
      age: data['age'] is int ? data['age'] : (data['age'] != null ? int.tryParse(data['age'].toString()) : null),
      department: data['department'],
      managerId: data['manager_id'],
      managerName: data['manager_name'],
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'photo_url': photoUrl,
      'company_name': companyName,
      'sector': sector,
      'age': age,
      'department': department,
      'manager_id': managerId,
      'manager_name': managerName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? department,
    String? companyName,
    String? sector,
    int? age,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      companyName: companyName ?? this.companyName,
      sector: sector ?? this.sector,
      age: age ?? this.age,
      department: department ?? this.department,
      managerId: managerId,
      managerName: managerName,
      createdAt: createdAt,
    );
  }
}
