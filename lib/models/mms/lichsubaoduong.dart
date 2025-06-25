import 'package:Thilogi/models/mms/hangmuc.dart';

class LichSuBaoDuongModel {
  String? id;
  String? tenDiaDiem;
  String? ngay;
  String? ngayXacNhan;
  String? loaiBaoDuong;
  String? tanSuat;
  String? giaTri;
  String? bienSo1;
  String? bienSo2;
  String? soKM;
  String? soChuyenXe;
  String? chiSo;
  String? noiDung;
  String? ketQua;
  String? nguoiYeuCau;
  String? nguoiXacNhan;
  String? phuongTien_Id;
  String? baoDuong_Id;
  String? chiPhi;
  String? chiPhi_TD;
  String? model_Id;
  String? model;
  String? model_Option;
  String? soKM_Adsun;
  String? trangThai;
  String? hinhAnh;
  bool? isYeuCau;
  bool? isThayDoi;
  bool? isVenDer;
  String? tinhTrang;
  String? ngayDiBaoDuong;
  String? ngayHoanThanh;
  String? ngayDiSuaChua;
  String? nguoiDiBaoDuong;
  String? nguoiDiSuaChua;
  String? nguoiXacNhanHoanThanh;
  String? nguoiDeXuatHoanThanh;
  String? ngayDeXuatHoanThanh;
  bool? isDuyet;
  bool? isBaoDuong;
  bool? isSuaChua;
  bool? isLenhHoanThanh;
  bool? isHoanThanh;
  String? diaDiem_Id;
  String? tongChiPhi;
  String? vatTuThayThe;
  String? chiPhiBD2;
  String? chiPhiSC2;
  String? danhSachHangMuc;
  List<HangMucModel>? lichSu;

  LichSuBaoDuongModel(
      {this.id,
      this.tenDiaDiem,
      this.ngay,
      this.trangThai,
      this.loaiBaoDuong,
      this.tanSuat,
      this.giaTri,
      this.bienSo1,
      this.bienSo2,
      this.soKM,
      this.soChuyenXe,
      this.chiSo,
      this.chiPhi,
      this.soKM_Adsun,
      this.ketQua,
      this.noiDung,
      this.model,
      this.chiPhi_TD,
      this.model_Option,
      this.isThayDoi,
      this.isVenDer,
      this.isYeuCau,
      this.baoDuong_Id,
      this.phuongTien_Id,
      this.nguoiYeuCau,
      this.ngayXacNhan,
      this.nguoiXacNhan,
      this.hinhAnh,
      this.isBaoDuong,
      this.isDuyet,
      this.isHoanThanh,
      this.model_Id,
      this.ngayDiBaoDuong,
      this.ngayHoanThanh,
      this.isLenhHoanThanh,
      this.nguoiDiBaoDuong,
      this.ngayDeXuatHoanThanh,
      this.nguoiDeXuatHoanThanh,
      this.diaDiem_Id,
      this.tinhTrang,
      this.nguoiXacNhanHoanThanh,
      this.isSuaChua,
      this.lichSu,
      this.ngayDiSuaChua,
      this.nguoiDiSuaChua,
      this.vatTuThayThe,
      this.chiPhiBD2,
      this.chiPhiSC2,
      this.danhSachHangMuc,
      this.tongChiPhi});
  factory LichSuBaoDuongModel.fromJson(Map<String, dynamic> json) {
    return LichSuBaoDuongModel(
        id: json["id"].toString(),
        tenDiaDiem: json["tenDiaDiem"],
        ngay: json["ngay"],
        loaiBaoDuong: json["loaiBaoDuong"],
        tanSuat: json["tanSuat"],
        giaTri: json["giaTri"],
        bienSo1: json["bienSo1"],
        soKM: json["soKM"],
        trangThai: json["trangThai"],
        soChuyenXe: json["soChuyenXe"],
        chiSo: json["chiSo"],
        chiPhi: json["chiPhi"],
        phuongTien_Id: json["phuongTien_Id"],
        noiDung: json["noiDung"],
        ketQua: json["ketQua"],
        baoDuong_Id: json["baoDuong_Id"],
        model: json["model"],
        model_Option: json["model_Option"],
        soKM_Adsun: json["soKM_Adsun"],
        nguoiYeuCau: json["nguoiYeuCau"],
        nguoiXacNhan: json["nguoiXacNhan"],
        hinhAnh: json["hinhAnh"],
        ngayXacNhan: json["ngayXacNhan"],
        ngayDiBaoDuong: json["ngayDiBaoDuong"],
        ngayHoanThanh: json["ngayHoanThanh"],
        nguoiDiBaoDuong: json["nguoiDiBaoDuong"],
        nguoiXacNhanHoanThanh: json["nguoiXacNhanHoanThanh"],
        isDuyet: json["isDuyet"],
        isBaoDuong: json["isBaoDuong"],
        isSuaChua: json["isSuaChua"],
        isLenhHoanThanh: json["isLenhHoanThanh"],
        tinhTrang: json["tinhTrang"],
        isYeuCau: json["isYeuCau"],
        diaDiem_Id: json["diaDiem_Id"],
        chiPhi_TD: json['chiPhi_TD'],
        ngayDeXuatHoanThanh: json['ngayDeXuatHoanThanh'],
        nguoiDeXuatHoanThanh: json['nguoiDeXuatHoanThanh'],
        ngayDiSuaChua: json['ngayDiSuaChua'],
        nguoiDiSuaChua: json['nguoiDiSuaChua'],
        tongChiPhi: json['tongChiPhi'],
        vatTuThayThe: json['vatTuThayThe'],
        chiPhiBD2: json['chiPhiBD2'],
        chiPhiSC2: json['chiPhiSC2'],
        bienSo2: json['bienSo2'],
        danhSachHangMuc: json['danhSachHangMuc'],
        lichSu: (json['lichSu'] as List<dynamic>?)?.map((e) => HangMucModel.fromJson(e as Map<String, dynamic>)).toList(),
        isHoanThanh: json["isHoanThanh"]);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'phuongTien_Id': phuongTien_Id,
        'baoDuong_Id': baoDuong_Id,
        'trangThai': trangThai,
        'noiDung': noiDung,
        'ketQua': ketQua,
        'hinhAnh': hinhAnh,
        'diaDiem_Id': diaDiem_Id,
        'vatTuThayThe': vatTuThayThe,
      };
}
