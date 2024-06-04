class NhanVienModel {
  final String? fullName;
  final String? email;
  final String? id;
  final bool? mustChangePass;
  final String? accessRole;
  final String? token;
  final String? refreshToken;
  final String? hinhAnhUrl;

  NhanVienModel({
    this.fullName,
    this.email,
    this.id,
    this.mustChangePass,
    this.token,
    this.refreshToken,
    this.hinhAnhUrl,
    this.accessRole,
  });
  factory NhanVienModel.fromJson(Map<String, dynamic> json) {
    return NhanVienModel(
      id: json["id"].toString(),
      email: json["email"],
      fullName: json["fullName"],
      mustChangePass: json["mustChangePass"],
      accessRole: json["accessRole"],
      token: json["token"],
      refreshToken: json["refreshToken"],
      hinhAnhUrl: json["hinhAnhUrl"],
    );
  }
}
