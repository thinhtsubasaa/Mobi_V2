class PhienBanModel {
  String? id;
  String? maPhienBan;
  String? moTa;


  PhienBanModel({this.id, this.maPhienBan, this.moTa});
  factory PhienBanModel.fromJson(Map<String, dynamic> json) {
    return PhienBanModel(id: json["id"].toString(), maPhienBan: json["maPhienBan"], moTa: json["moTa"]);
  }
}
