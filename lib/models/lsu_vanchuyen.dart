class LSXVanChuyenModel {
  String? id;
  String? gioNhan;
  String? bienSo;
  String? loaiXe;
  String? soKhung;
  String? thongTinVanChuyen;
  String? thongTinChiTiet;
  String? nguoiVanChuyen;

  LSXVanChuyenModel({this.id, this.gioNhan, this.bienSo, this.loaiXe, this.soKhung, this.thongTinVanChuyen, this.thongTinChiTiet, this.nguoiVanChuyen});
  factory LSXVanChuyenModel.fromJson(Map<String, dynamic> json) {
    return LSXVanChuyenModel(
      id: json["id"].toString(),
      gioNhan: json["gioNhan"],
      bienSo: json["bienSo"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      thongTinChiTiet: json["thongTinChiTiet"],
      thongTinVanChuyen: json["thongTinVanChuyen"],
      nguoiVanChuyen: json["nguoiVanChuyen"],
    );
  }
}
