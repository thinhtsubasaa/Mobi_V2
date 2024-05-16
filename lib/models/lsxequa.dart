class LSXeQuaModel {
  String? id;
  String? tuNgay;
  String? noiNhan;
  String? nguoiNhan;
  String? toaDo;

  LSXeQuaModel(
      {this.id, this.tuNgay, this.nguoiNhan, this.noiNhan, this.toaDo});
  factory LSXeQuaModel.fromJson(Map<String, dynamic> json) {
    return LSXeQuaModel(
      id: json["id"].toString(),
      tuNgay: json["tuNgay"],
      nguoiNhan: json["nguoiNhan"],
      noiNhan: json["noiNhan"],
      toaDo: json["toaDo"],
    );
  }
}
