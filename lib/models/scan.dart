class ScanModel {
  String? nhapXuatKhoId;
  String chiTietId;
  String soKhung;
  String? chuyenId;
  String barCodeId;
  String tenChiTiet;
  String tenSanPham;
  String tenMau;
  String maCode;
  String? ngay;
  bool isNhapKho;

  ScanModel({
    this.nhapXuatKhoId,
    required this.chiTietId,
    required this.soKhung,
    this.chuyenId,
    required this.barCodeId,
    required this.tenChiTiet,
    required this.tenSanPham,
    required this.tenMau,
    required this.maCode,
    this.ngay,
    required this.isNhapKho,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      nhapXuatKhoId: json["nhapXuatKhoId"],
      chiTietId: json["chiTietId"],
      soKhung: json["soKhung"],
      chuyenId: json["chuyenId"],
      barCodeId: json["barCodeId"],
      tenChiTiet: json["tenChiTiet"],
      tenSanPham: json["tenSanPham"],
      tenMau: json["tenMau"],
      maCode: json["maCode"],
      ngay: json["ngay"],
      isNhapKho: json["isNhapKho"],
    );
  }

  Map<String, dynamic> toJson() => {
        'nhapXuatKhoId': nhapXuatKhoId,
        'chiTietId': chiTietId,
        'soKhung': soKhung,
        'chuyenId': chuyenId,
        'barCodeId': barCodeId,
        'tenChiTiet': tenChiTiet,
        'tenSanPham': tenSanPham,
        'tenMau': tenMau,
        'maCode': maCode,
        'ngay': ngay,
        'isNhapKho': isNhapKho,
      };
}
