class NoiDenModel {
  String? id;
  String? noiDen;
  String? bienSo;
  String? doiTac_Id;

  NoiDenModel({this.id, this.noiDen, this.bienSo, this.doiTac_Id});
  factory NoiDenModel.fromJson(Map<String, dynamic> json) {
    return NoiDenModel(id: json["id"].toString(), noiDen: json["noiDen"], bienSo: json["bienSo"], doiTac_Id: json["doiTac_Id"].toString());
  }
}
