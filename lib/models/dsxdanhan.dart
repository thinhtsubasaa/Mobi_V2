class DS_DaNhanModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? mauXe;
  String? nguoiNhan;
  String? gioNhan;

  DS_DaNhanModel(
      {this.id,
      this.loaiXe,
      this.soKhung,
      this.mauXe,
      this.gioNhan,
      this.nguoiNhan});

  factory DS_DaNhanModel.fromJson(Map<String, dynamic> json) {
    return DS_DaNhanModel(
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      mauXe: json["mauXe"],
      nguoiNhan: json["nguoiNhan"],
      gioNhan: json["gioNhan"],
    );
  }
}
