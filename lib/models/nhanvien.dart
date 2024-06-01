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
      // ngay: json["ngay"],
      // noiGiao: json["noiGiao"],
      // soTBGX: json["soTBGX"],
      // toaDo: json["toaDo"],
      // nguoiPhuTrach: json["nguoiPhuTrach"],
    );
  }
}
