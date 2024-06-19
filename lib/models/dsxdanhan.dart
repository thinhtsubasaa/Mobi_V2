class DS_DaNhanModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? maNhanVien;
  String? gioNhan;

  DS_DaNhanModel(
      {this.id, this.loaiXe, this.soKhung, this.maNhanVien, this.gioNhan});

  factory DS_DaNhanModel.fromJson(Map<String, dynamic> json) {
    return DS_DaNhanModel(
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      maNhanVien: json["maNhanVien"],
      gioNhan: json["gioNhan"],
    );
  }
}
