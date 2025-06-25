class DonViModel {
  String? id;
  String? maDonVi;
  String? tenDonVi;

  DonViModel({
    this.id,
    this.tenDonVi,
    this.maDonVi,
  });
  factory DonViModel.fromJson(Map<String, dynamic> json) {
    return DonViModel(id: json["id"].toString(), tenDonVi: json["tenDonVi"], maDonVi: json["maDonVi"]);
  }
}
