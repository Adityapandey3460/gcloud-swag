// lib/models/student.dart

class Student {
  final String id;
  final String name;
  final String email;
  final String college;
  final String phone;
  final bool claimed;
  final DateTime registeredAt;
  final DateTime? claimedAt;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    this.phone = '',
    required this.claimed,
    required this.registeredAt,
    this.claimedAt,
  });

  factory Student.fromFirestore(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      college: data['college'] ?? '',
      phone: data['phone'] ?? '',
      claimed: data['claimed'] ?? false,
      registeredAt: data['registeredAt'] != null
          ? (data['registeredAt'] as dynamic).toDate()
          : DateTime.now(),
      claimedAt: data['claimedAt'] != null
          ? (data['claimedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'college': college,
      'phone': phone,
      'claimed': claimed,
      'registeredAt': registeredAt,
      'claimedAt': claimedAt,
    };
  }
}
