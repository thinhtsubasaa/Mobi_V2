import 'package:Thilogi/models/sis/lua_chon.dart';

class CauHoiPhanThiBaiThiModel {
  final String id;
  final String cauHoiId;
  final int thuTu;
  final double? diemPhanBo;
  final String noiDung;
  final String loaiCauHoi;
  final String? hinhAnhUrl;
  final String? amThanhUrl;
  final String? menhDeIds;
  final List<LuaChonModel> luaChons;

  CauHoiPhanThiBaiThiModel({
    required this.id,
    required this.cauHoiId,
    required this.thuTu,
    required this.diemPhanBo,
    required this.noiDung,
    required this.loaiCauHoi,
    required this.hinhAnhUrl,
    required this.amThanhUrl,
    required this.menhDeIds,
    required this.luaChons,
  });

  factory CauHoiPhanThiBaiThiModel.fromJson(Map<String, dynamic> json) {
    return CauHoiPhanThiBaiThiModel(
      id: json["id"],
      cauHoiId: json["cauHoiId"],
      thuTu: json["thuTu"],
      diemPhanBo: json["diemPhanBo"],
      noiDung: json["noiDung"],
      loaiCauHoi: json["loaiCauHoi"],
      hinhAnhUrl: json["hinhAnhUrl"],
      amThanhUrl: json["amThanhUrl"],
      menhDeIds: json["menhDeIds"],
      luaChons: (json["luaChons"] as List)
          .map((item) => LuaChonModel.fromJson(item))
          .toList(),
    );
  }
}