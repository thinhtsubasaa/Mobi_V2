class ScanModel {
  String? id;
  String soKhung;
  String? chuyenId;
  String barCodeId;
  String tenSanPham;
  String tenMau;
  String maCode;
  String? ngay;

  ScanModel({
    this.id,
    required this.soKhung,
    this.chuyenId,
    required this.barCodeId,
    required this.tenSanPham,
    required this.tenMau,
    required this.maCode,
    this.ngay,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json["id"],
      soKhung: json["soKhung"],
      chuyenId: json["chuyenId"],
      barCodeId: json["barCodeId"],
      tenSanPham: json["tenSanPham"],
      tenMau: json["tenMau"],
      maCode: json["maCode"],
      ngay: json["ngay"],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'soKhung': soKhung,
        'chuyenId': chuyenId,
        'barCodeId': barCodeId,
        'tenSanPham': tenSanPham,
        'tenMau': tenMau,
        'maCode': maCode,
        'ngay': ngay,
      };
}
