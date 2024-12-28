import 'package:Thilogi/models/chuyenxe.dart';

class LSX_RaCongModel {
  String? id;
  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? tenBaoVe;
  String? tenTaiXe;
  String? gioRa;
  String? ngayRaCong;
  String? noiDen;
  String? ghiChu;
  String? lyDo;
  String? hinhAnh;
  String? noiDi;
  String? bienSo;
  String? trangThaiChuyenXe;
  String? tongXeDaCheck_TongXe;
  String? hinhAnhTaiXe;
  bool? isOke;
  bool? isKiemTra;

  List<ChuyenXeModel>? chuyenXe;

  LSX_RaCongModel(
      {this.id,
      this.soKhung,
      this.soMay,
      this.mauXe,
      this.tenBaoVe,
      this.tenTaiXe,
      this.gioRa,
      this.loaiXe,
      this.ngayRaCong,
      this.noiDen,
      this.ghiChu,
      this.hinhAnh,
      this.noiDi,
      this.lyDo,
      this.bienSo,
      this.isOke,
      this.isKiemTra,
      this.chuyenXe,
      this.trangThaiChuyenXe,
      this.hinhAnhTaiXe,
      this.tongXeDaCheck_TongXe});
  factory LSX_RaCongModel.fromJson(Map<String, dynamic> json) {
    return LSX_RaCongModel(
        id: json["id"].toString(),
        soKhung: json["soKhung"],
        soMay: json["soMay"],
        mauXe: json["mauXe"],
        tenBaoVe: json["tenBaoVe"],
        tenTaiXe: json["tenTaiXe"],
        loaiXe: json["loaiXe"],
        gioRa: json["gioRa"],
        ngayRaCong: json["ngayRaCong"],
        noiDen: json["noiDen"],
        ghiChu: json["ghiChu"],
        lyDo: json["lyDo"],
        hinhAnh: json["hinhAnh"],
        bienSo: json["bienSo"],
        trangThaiChuyenXe: json["trangThaiChuyenXe"],
        isOke: json["isOke"],
        isKiemTra: json["isKiemTra"],
        hinhAnhTaiXe: json["hinhAnhTaiXe"],
        tongXeDaCheck_TongXe: json["tongXeDaCheck_TongXe"],
        chuyenXe: (json['chuyenXe'] as List<dynamic>?)?.map((e) => ChuyenXeModel.fromJson(e as Map<String, dynamic>)).toList(),
        noiDi: json["noiDi"]);
  }
}
