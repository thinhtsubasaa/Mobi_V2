class PhongBanKPIModel {
  String? phongBanThaco_Id;
  int? capDo;

  String? maPhongBan;
  String? tenPhongBan;
  String? vptq_kpi_DonViKPI_Id;
  String? maDonViKPI;
  String? tenDonViKPI;

  PhongBanKPIModel({
    this.phongBanThaco_Id,
    this.capDo,
    this.maPhongBan,
    this.maDonViKPI,
    this.tenDonViKPI,
    this.vptq_kpi_DonViKPI_Id,
    this.tenPhongBan,
  });
  factory PhongBanKPIModel.fromJson(Map<String, dynamic> json) {
    return PhongBanKPIModel(
      vptq_kpi_DonViKPI_Id: json["vptq_kpi_DonViKPI_Id"].toString(),
      tenDonViKPI: json["tenDonViKPI"],
      maDonViKPI: json["maDonViKPI"],
      tenPhongBan: json["tenPhongBan"],
      maPhongBan: json["maPhongBan"],
      phongBanThaco_Id: json["phongBanThaco_Id"].toString(),
      capDo: json["capDo"],
    );
  }
}
