class KhoXeModel {
  String? id;
  String? maKhoXe;
  String? tenKhoXe;
  bool? isLogistic;
  String? soMay;

  KhoXeModel({
    this.id,
    this.maKhoXe,
    this.tenKhoXe,
    this.isLogistic,
    this.soMay,
  });
  factory KhoXeModel.fromJson(Map<String, dynamic> json) {
    return KhoXeModel(
      id: json["id"].toString(),
      maKhoXe: json["maKhoXe"],
      tenKhoXe: json["tenKhoXe"],
      isLogistic: json["isLogistic"],
    );
  }
}
