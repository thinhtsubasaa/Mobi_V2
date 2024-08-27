class DS_RaCongModel {
  String? id;
  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? tenBaoVe;
  String? tenTaiXe;
  String? gioRa;
  String? ngayRaCong;

  DS_RaCongModel({
    this.id,
    this.soKhung,
    this.soMay,
    this.mauXe,
    this.tenBaoVe,
    this.tenTaiXe,
    this.gioRa,
    this.loaiXe,
    this.ngayRaCong,
  });

  factory DS_RaCongModel.fromJson(Map<String, dynamic> json) {
    return DS_RaCongModel(
      id: json["id"].toString(),
      soKhung: json["soKhung"],
      soMay: json["soMay"],
      mauXe: json["mauXe"],
      tenBaoVe: json["tenBaoVe"],
      tenTaiXe: json["tenTaiXe"],
      loaiXe: json["loaiXe"],
      gioRa: json["gioRa"],
      ngayRaCong: json["ngayRaCong"],
    );
  }
}
