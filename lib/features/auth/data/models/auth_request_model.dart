class AuthRequestModel {
  final String login;
  final String password;

  const AuthRequestModel({
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'Login': login,
        'Password': password,
      };
}
