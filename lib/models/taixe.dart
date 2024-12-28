class TaiXeModel {
  String? id;
  String? maTaiXe;
  String? tenTaiXe;
  String? hangBang;
  String? soDienThoai;
  String? doiTac_Id;

  TaiXeModel({this.id, this.maTaiXe, this.tenTaiXe, this.hangBang, this.soDienThoai, this.doiTac_Id});
  factory TaiXeModel.fromJson(Map<String, dynamic> json) {
    return TaiXeModel(id: json["id"].toString(), maTaiXe: json["maTaiXe"], tenTaiXe: json["tenTaiXe"], hangBang: json["hangBang"], soDienThoai: json["soDienThoai"], doiTac_Id: json["doiTac_Id"]);
  }
}
