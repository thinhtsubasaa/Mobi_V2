class DonViKPIModel {
  String? vptq_kpi_DonViKPI_Id;
  String? maDonViKPI;
  String? tenDonViKPI;
  String? tienToDanhMucPI;
  bool? isCongTy;

  DonViKPIModel({
    this.vptq_kpi_DonViKPI_Id,
    this.tenDonViKPI,
    this.maDonViKPI,
    this.tienToDanhMucPI,
    this.isCongTy,
  });
  factory DonViKPIModel.fromJson(Map<String, dynamic> json) {
    return DonViKPIModel(
      vptq_kpi_DonViKPI_Id: json["vptq_kpi_DonViKPI_Id"].toString(),
      tenDonViKPI: json["tenDonViKPI"],
      maDonViKPI: json["maDonViKPI"],
      tienToDanhMucPI: json["tienToDanhMucPI"],
      isCongTy: json["isCongTy"] == 1 ? true : false,
    );
  }
}
