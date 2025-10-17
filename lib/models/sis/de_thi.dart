class DeThiModel {
  final String id;
  final String maDeThi;
  final String tenDeThi;
  final String? moTa;
  final int duration;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  final int totalQuestions;
  final double diemToiDa;
  final double diemDat;
  final bool isAllowed;
  final bool isPassed;
  final DateTime? nextAvailableTime;

  DeThiModel({
    required this.id,
    required this.maDeThi,
    required this.tenDeThi,
    required this.moTa,
    required this.duration,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.totalQuestions,
    required this.diemToiDa,
    required this.diemDat,
    required this.isAllowed,
    required this.isPassed,
    required this.nextAvailableTime,
  });

  factory DeThiModel.fromJson(Map<String, dynamic> json) {
    return DeThiModel(
      id: json["id"],
      maDeThi: json["maDeThi"],
      tenDeThi: json["tenDeThi"],
      moTa: json["moTa"],
      duration: json["duration"],
      thoiGianBatDau: json["thoiGianBatDau"],
      thoiGianKetThuc: json["thoiGianKetThuc"],
      totalQuestions: json["totalQuestions"],
      diemToiDa: (json["diemToiDa"] as num?)?.toDouble() ?? 0.0,
      diemDat: (json["diemDat"] as num?)?.toDouble() ?? 0.0,
      isAllowed: json["isAllowed"],
      isPassed: json["isPassed"],
      nextAvailableTime: json["nextAvailableTime"] == null ? null : DateTime.parse(json["nextAvailableTime"]),
    );
  }
}
