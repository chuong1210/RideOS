class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String role;
  final double? rating;
  final int? totalTrips;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.role,
    this.rating,
    this.totalTrips,
    required this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'],
      rating: json['rating']?.toDouble(),
      totalTrips: json['totalTrips'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'rating': rating,
      'totalTrips': totalTrips,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

