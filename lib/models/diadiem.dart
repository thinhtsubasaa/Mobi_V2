class DiaDiemModel {
  String? id;
  String? maDiaDiem;
  String? tenDiaDiem;
  String? diachi;

  DiaDiemModel({
    this.id,
    this.tenDiaDiem,
    this.diachi,
    this.maDiaDiem,
  });
  factory DiaDiemModel.fromJson(Map<String, dynamic> json) {
    return DiaDiemModel(
      id: json["id"].toString(),
      tenDiaDiem: json["tenDiaDiem"],
      diachi: json["diachi"],
      maDiaDiem: json["maDiaDiem"]
    );
  }
}
