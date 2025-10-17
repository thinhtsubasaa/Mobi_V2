class KyDanhGiaModel {
  final String? id;
  final int? chuKy; // 1: Tháng, 2: Quý, 3: Năm (ví dụ)
  final String? thoiDiem; // "08/2025"
  final int? thang; // 8
  final int? nam; // 2025
  final int? kyQuy; // 0 nếu theo tháng
  final bool? isDaTaoRandom;
  final String? denNgay; // "31/08/2025"
  final String? tuNgay; // "05/08/2025"

  final String? vptqKpiThangDiemXepLoaiId; // vptq_kpi_ThangDiemXepLoai_Id
  final String? tenThangDiemXepLoai;

  const KyDanhGiaModel({
    this.id,
    this.chuKy,
    this.thoiDiem,
    this.thang,
    this.nam,
    this.kyQuy,
    this.isDaTaoRandom,
    this.denNgay,
    this.tuNgay,
    this.vptqKpiThangDiemXepLoaiId,
    this.tenThangDiemXepLoai,
  });

  factory KyDanhGiaModel.fromJson(Map<String, dynamic> json) => KyDanhGiaModel(
        id: json['id']?.toString(),
        chuKy: (json['chuKy'] as num?)?.toInt(),
        thoiDiem: json['thoiDiem'],
        thang: (json['thang'] as num?)?.toInt(),
        nam: (json['nam'] as num?)?.toInt(),
        kyQuy: (json['kyQuy'] as num?)?.toInt(),
        isDaTaoRandom: json['isDaTaoRandom'] is bool ? json['isDaTaoRandom'] as bool : json['isDaTaoRandom']?.toString().toLowerCase() == 'true',
        denNgay: json['denNgay'],
        tuNgay: json['tuNgay'],
        vptqKpiThangDiemXepLoaiId: json['vptq_kpi_ThangDiemXepLoai_Id']?.toString(),
        tenThangDiemXepLoai: json['tenThangDiemXepLoai'],
      );
}
