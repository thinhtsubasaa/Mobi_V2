class UserModel {
  final String? fullName;
  final String? email;
  final String? id;
  final bool? mustChangePass;
  final String? token;
  final String? refreshToken;
  final String? hinhAnhUrl;

  UserModel({
    this.fullName,
    this.email,
    this.id,
    this.mustChangePass,
    this.token,
    this.refreshToken,
    this.hinhAnhUrl,
  });
}
