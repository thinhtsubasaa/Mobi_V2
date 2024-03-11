class ScanModel {
  String? id;
  String? soKhung;
  String? tenSanPham;
  String? tenMau;
  String? tenKho;
  String? soMay;
  String? ngayXuatKhoView;
  String? tenTaiXe;
  String? ghiChu;
  List<PhuKien>? phuKien;

  ScanModel({
    this.id,
    this.soKhung,
    this.tenSanPham,
    this.tenMau,
    this.tenKho,
    this.soMay,
    this.ngayXuatKhoView,
    this.tenTaiXe,
    this.ghiChu,
    this.phuKien,
  });
  @override
  String toString() {
    return 'ScanModel(id: $id, soKhung: $soKhung, tenSanPham: $tenSanPham, tenMau: $tenMau, tenKho: $tenKho, soMay: $soMay, ngayXuatKhoView: $ngayXuatKhoView, tenTaiXe: $tenTaiXe, ghiChu: $ghiChu, phuKien: $phuKien)';
  }

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json["id"],
      soKhung: json["soKhung"],
      tenSanPham: json["tenSanPham"],
      tenMau: json["tenMau"],
      tenKho: json["tenKho"],
      soMay: json["soMay"],
      ngayXuatKhoView: json["ngayXuatKhoView"],
      tenTaiXe: json["tenTaiXe"],
      ghiChu: json["ghiChu"],
      phuKien:
          (json['phuKien'] as List).map((e) => PhuKien.fromJson(e)).toList(),
    );
  }
}

class PhuKien {
  String? phuKien_Id;
  String? giaTri;
  String? tenPhuKien;

  PhuKien({
    this.phuKien_Id,
    this.giaTri,
    this.tenPhuKien,
  });
  @override
  String toString() {
    return 'ScanModel(phuKien_Id: $phuKien_Id, giaTri: $giaTri, tenPhuKien: $tenPhuKien)';
  }

  factory PhuKien.fromJson(Map<String, dynamic> json) {
    return PhuKien(
      phuKien_Id: json['phuKien_Id'],
      giaTri: json['giaTri'],
      tenPhuKien: json['tenPhuKien'],
    );
  }
}
