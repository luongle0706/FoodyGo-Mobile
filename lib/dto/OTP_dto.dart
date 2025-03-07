class OTPResponseDTO {
  final String message;
  final String otp;
  final bool existedEmail;

  OTPResponseDTO(
      {required this.message, required this.otp, required this.existedEmail});
}
