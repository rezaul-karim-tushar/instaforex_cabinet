class AuthResponseModel {
  final String? peanutToken;
  final String? partnerToken;
  final bool isSuccess;
  final String? errorMessage;

  const AuthResponseModel({
    this.peanutToken,
    this.partnerToken,
    required this.isSuccess,
    this.errorMessage,
  });
}
