class LichSuModel {
  String? vptq_kpi_KPICaNhanVersion_Id;
  String? thoiGian;
  int? lanChinhSua;
  String? nguoiChinhSua_Id;
  String? tenNguoiChinhSua;
  String? maNguoiChinhSua;
  String? vptq_kpi_KPICaNhan_Id;
  LichSuModel({this.lanChinhSua, this.maNguoiChinhSua, this.nguoiChinhSua_Id, this.tenNguoiChinhSua, this.thoiGian, this.vptq_kpi_KPICaNhanVersion_Id, this.vptq_kpi_KPICaNhan_Id});

  factory LichSuModel.fromJson(Map<String, dynamic> j) => LichSuModel(
      vptq_kpi_KPICaNhanVersion_Id: j['vptq_kpi_KPICaNhanVersion_Id'].toString(),
      vptq_kpi_KPICaNhan_Id: j['vptq_kpi_KPICaNhan_Id'].toString(),
      thoiGian: j['thoiGian'],
      lanChinhSua: j['lanChinhSua'] as int,
      nguoiChinhSua_Id: j['nguoiChinhSua_Id'].toString(),
      tenNguoiChinhSua: j['tenNguoiChinhSua'],
      maNguoiChinhSua: j['maNguoiChinhSua']);
}
