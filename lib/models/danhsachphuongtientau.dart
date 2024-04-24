class DanhSachPhuongTienTauModel {
  String? id;
  String? tenPhuongTien;
  String? tenLoaiPhuongTien;
  String? bienSo;

  DanhSachPhuongTienTauModel({
    this.id,
    this.tenPhuongTien,
    this.tenLoaiPhuongTien,
    this.bienSo,
  });
  factory DanhSachPhuongTienTauModel.fromJson(Map<String, dynamic> json) {
    return DanhSachPhuongTienTauModel(
      id: json["id"].toString(),
      tenPhuongTien: json["tenPhuongTien"],
      tenLoaiPhuongTien: json["tenLoaiPhuongTien"],
      bienSo: json["bienSo"],
    );
  }
}
