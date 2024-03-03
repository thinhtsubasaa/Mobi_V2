class ScanModel {
  String? nhapXuatKhoId;
  String chiTietId;
  String? sanPhamId;
  String? chuyenId;
  String barCodeId;
  String tenChiTiet;
  String tenSanPham;
  String tenDongXe;
  String maCode;
  String? ngay;
  bool isNhapKho;

  ScanModel({
    this.nhapXuatKhoId,
    required this.chiTietId,
    this.sanPhamId,
    this.chuyenId,
    required this.barCodeId,
    required this.tenChiTiet,
    required this.tenSanPham,
    required this.tenDongXe,
    required this.maCode,
    this.ngay,
    required this.isNhapKho,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      nhapXuatKhoId: json["nhapXuatKhoId"],
      chiTietId: json["chiTietId"],
      sanPhamId: json["sanPhamId"],
      chuyenId: json["chuyenId"],
      barCodeId: json["barCodeId"],
      tenChiTiet: json["tenChiTiet"],
      tenSanPham: json["tenSanPham"],
      tenDongXe: json["tenDongXe"],
      maCode: json["maCode"],
      ngay: json["ngay"],
      isNhapKho: json["isNhapKho"],
    );
  }

  Map<String, dynamic> toJson() => {
        'nhapXuatKhoId': nhapXuatKhoId,
        'chiTietId': chiTietId,
        'sanPhamId': sanPhamId,
        'chuyenId': chuyenId,
        'barCodeId': barCodeId,
        'tenChiTiet': tenChiTiet,
        'tenSanPham': tenSanPham,
        'tenDongXe': tenDongXe,
        'maCode': maCode,
        'ngay': ngay,
        'isNhapKho': isNhapKho,
      };
}
