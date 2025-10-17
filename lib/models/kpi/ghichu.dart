class GhiChuModel {
  final String vptq_kpi_KPICaNhanGhiChu_Id; // vptq_kpi_KPICaNhanGhiChu_Id
  final String vptq_kpi_KPICaNhan_Id; // vptq_kpi_KPICaNhan_Id
  final String nguoiDuyet_Id; // nguoiDuyet_Id
  final int thuTu; // thuTu
  final String ghiChu; // ghiChu
  final String tenNguoiDuyet; // tenNguoiDuyet
  final String? tenPhongBan; // TenPhongBan
  final String ngayTaoRaw; // "15/09/2025 15:05"
  final String? ngayTao; // parsed từ ngayTaoRaw (có thể null nếu format lạ)

  GhiChuModel({
    required this.vptq_kpi_KPICaNhanGhiChu_Id,
    required this.vptq_kpi_KPICaNhan_Id,
    required this.nguoiDuyet_Id,
    required this.thuTu,
    required this.ghiChu,
    required this.tenNguoiDuyet,
    required this.ngayTaoRaw,
    this.tenPhongBan,
    this.ngayTao,
  });

  factory GhiChuModel.fromJson(Map<String, dynamic> j) {
    final raw = (j['ngayTao'] ?? '').toString();
    return GhiChuModel(
      vptq_kpi_KPICaNhanGhiChu_Id: (j['vptq_kpi_KPICaNhanGhiChu_Id'] ?? '').toString(),
      vptq_kpi_KPICaNhan_Id: (j['vptq_kpi_KPICaNhan_Id'] ?? '').toString(),
      nguoiDuyet_Id: (j['nguoiDuyet_Id'] ?? '').toString(),
      thuTu: (j['thuTu'] ?? 0) as int,
      ghiChu: (j['ghiChu'] ?? '').toString(),
      tenNguoiDuyet: (j['tenNguoiDuyet'] ?? '').toString(),
      tenPhongBan: j['TenPhongBan']?.toString(),
      ngayTaoRaw: raw,
      ngayTao: j['ngayTao'],
    );
  }
}
