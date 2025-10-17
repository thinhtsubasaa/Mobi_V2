import 'package:Thilogi/models/sis/phan_thi_bai_thi.dart';

class BaiThiModel {
  final String id;
  final String deThiId;
  final String? userId;
  final int? duration;
  final DateTime thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final double? maxScore;
  final double? totalScore;
  final List<PhanThiBaiThiModel> phanThiBaiThis;

  BaiThiModel({
    required this.id,
    required this.deThiId,
    required this.userId,
    required this.duration,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.maxScore,
    required this.totalScore,
    required this.phanThiBaiThis,
  });

  factory BaiThiModel.fromJson(Map<String, dynamic> json) {
    return BaiThiModel(
      id: json["id"],
      deThiId: json["deThiId"],
      userId: json["userId"],
      duration: json["duration"],
      // parse ISO8601 string thành DateTime
      thoiGianBatDau: DateTime.parse(json["thoiGianBatDau"]),
      thoiGianKetThuc: json["thoiGianKetThuc"] == null ? null : DateTime.parse(json["thoiGianKetThuc"]),
      maxScore: json["maxScore"],
      totalScore: json["totalScore"],
      phanThiBaiThis: (json["phanThiBaiThis"] as List)
          .map((item) => PhanThiBaiThiModel.fromJson(item))
          .toList(),
    );
  }
}