// lib/models/student.dart

class Student {
  final String id;
  final String name;
  final String email;
  final String department;
  final String year;
  final bool claimed;
  final String tshirtSize;
  final DateTime? claimedAt;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    required this.claimed,
    required this.tshirtSize,
    this.claimedAt,
  });

factory Student.fromFirestore(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      year: data['year'] ?? '',
      claimed: data['claimed'] ?? false,
      tshirtSize: data['tshirtSize'] ?? '', 
      claimedAt: data['claimedAt'] != null
          ? (data['claimedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'year': year,
      'claimed': claimed,
      'tshirtSize': tshirtSize,
      'claimedAt': claimedAt,
    };
  }
}
