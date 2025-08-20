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
    return AuthModel(
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      userId: json['userId'] as String?,
      token: json['token'] as String?,
    );
  }
}