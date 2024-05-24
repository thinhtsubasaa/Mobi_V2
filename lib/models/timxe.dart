class TimXeModel {
  String? key;
  String? id;
  String? soKhung;
  String? tenKho;
  String? tenBaiXe;
  String? tenViTri;
  String? toaDo;

  TimXeModel(
      {this.key,
      this.id,
      this.tenViTri,
      this.soKhung,
      this.tenKho,
      this.tenBaiXe,
      this.toaDo});

  factory TimXeModel.fromJson(Map<String, dynamic> json) {
    return TimXeModel(
        key: json["key"],
        id: json["id"],
        soKhung: json["soKhung"],
        tenKho: json["tenKho"],
        tenViTri: json["tenViTr"],
        tenBaiXe: json["tenBaiXe"],
        toaDo: json["toaDo"]);
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'soKhung': soKhung,
        'tenKho': tenKho,
        'tenBaiXe': tenBaiXe,
        'tenViTri': tenViTri,
        'toaDo': toaDo,
      };
}
