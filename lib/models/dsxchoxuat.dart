class DS_ChoXuatModel {
  String? key;
  String? id;

  String? loaiXe;
  String? soKhung;
  bool? isKeHoach;

  DS_ChoXuatModel(
      {this.key, this.id, this.loaiXe, this.soKhung, this.isKeHoach});

  factory DS_ChoXuatModel.fromJson(Map<String, dynamic> json) {
    return DS_ChoXuatModel(
      key: json["key"],
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      isKeHoach: json["isKeHoach"],
    );
  }
}
