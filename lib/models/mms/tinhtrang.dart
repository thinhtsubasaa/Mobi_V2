class TinhTrangModel {
  String? id;
  String? name;
  String? arrange;

  TinhTrangModel({
    this.id,
    this.name,
    this.arrange,
  });
  factory TinhTrangModel.fromJson(Map<String, dynamic> json) {
    return TinhTrangModel(id: json["id"].toString(), name: json["name"], arrange: json["arrange"]);
  }
}
