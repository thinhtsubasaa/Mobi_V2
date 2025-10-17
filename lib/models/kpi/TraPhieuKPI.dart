class Approver {
  int viTriDuyet;
  bool isDuyet;
  String tenNguoiDuyet;
  String? thoiGianDuyet;

  Approver({
    required this.viTriDuyet,
    required this.isDuyet,
    required this.tenNguoiDuyet,
    required this.thoiGianDuyet,
  });

  factory Approver.fromJson(Map<String, dynamic> j) => Approver(
        viTriDuyet: (j['viTriDuyet'] ?? j['viTriDuyetDanhGia']) as int,
        isDuyet: j['isDuyet'] as bool,
        thoiGianDuyet: j['thoiGianDuyet'],
        tenNguoiDuyet: (j['tenViTriDuyet'] ?? j['tenNguoiDuyet'] ?? '').toString(),
      );
}
