class LoginModel {
  final String phone;
  final String password;
  final String? userId;
  final String? token;

  LoginModel({
    required this.phone,
    required this.password,
    this.userId,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
    };
  }

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      phone: json['phone'] as String? ?? '',
      password: json['password'] as String? ?? '',
      userId: json['userId'] as String?,
      token: json['token'] as String?,
    );
  }
}