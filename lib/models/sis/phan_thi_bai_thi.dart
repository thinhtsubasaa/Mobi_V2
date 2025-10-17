import 'package:Thilogi/models/sis/cau_hoi_phan_thi_bai_thi.dart';

class PhanThiBaiThiModel {
  final String id;
  final String tenPhanThiBaiThi;
  final int thuTu;
  final List<CauHoiPhanThiBaiThiModel> cauHoiPhanThiBaiThis;

  PhanThiBaiThiModel({
    required this.id,
    required this.tenPhanThiBaiThi,
    required this.thuTu,
    required this.cauHoiPhanThiBaiThis,
  });

  factory PhanThiBaiThiModel.fromJson(Map<String, dynamic> json) {
    return PhanThiBaiThiModel(
      id: json["id"],
      tenPhanThiBaiThi: json["tenPhanThiBaiThi"],
      thuTu: json["thuTu"],
      cauHoiPhanThiBaiThis: (json["cauHoiPhanThiBaiThis"] as List)
          .map((item) => CauHoiPhanThiBaiThiModel.fromJson(item))
          .toList(),
    );
  }
}