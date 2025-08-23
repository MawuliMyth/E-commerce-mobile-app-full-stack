// features/auth/models/auth_model.dart
class AuthModel {
  final String fullname;
  final String email;
  final String password;
  final String phone;
  final String? userId;
  final String? token;

  AuthModel({
    required this.fullname,
    required this.email,
    required this.password,
    required this.phone,
    this.userId,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    print('AuthModel.fromJson: Raw JSON = $json');
    final authModel = AuthModel(
      fullname: json['fullname'] as String? ?? json['name'] as String? ?? 'Guest',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      userId: json['id'] as String? ?? json['userId'] as String?,
      token: json['token'] as String?,
    );
    print('AuthModel.fromJson: Created AuthModel with fullname=${authModel.fullname}, userId=${authModel.userId}');
    return authModel;
  }
}