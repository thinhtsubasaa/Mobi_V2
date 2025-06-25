import 'package:Thilogi/models/mms/hangmuc.dart';

class PhuongTienModel {
  String? id;
  String? model;
  String? model_Option;
  String? bienSo1;
  String? bienSo2;
  String? soKhung;
  String? donViSuDung;
  String? tinhTrang;
  String? loaiPT;
  String? soKM_Adsun;
  String? soKM;
  String? ghiChu;
  bool? isDenHan;
  String? giaTri;
  String? model_Id;
  String? ngay;
  String? ngayXacNhan;
  String? ngayDiBaoDuong;
  String? ngayDiSuaChua;
  String? ngayHoanThanh;
  String? nguoiYeuCau;
  String? nguoiXacNhan;
  String? nguoiDeXuatHoanThanh;
  String? ngayDeXuatHoanThanh;
  String? nguoiDiBaoDuong;
  String? nguoiDiSuaChua;
  String? nguoiXacNhanHoanThanh;
  String? nguoiPhuTrach;
  String? noiDung;
  String? ketQua;
  String? tenDiaDiem;
  String? chiPhi;
  String? chiPhi_TD;
  String? maNhanVien;
  String? diaDiem_Id;
  String? hinhAnh;
  bool? isYeuCau;
  bool? isDuyet;
  bool? isBaoDuong;
  bool? isLenhHoanThanh;
  bool? isHoanThanh;
  bool? isDuyetSC;
  bool? isSuaChua;
  bool? isLenhHoanThanhSC;
  bool? isHoanThanhSC;
  bool? isYeuCauSC;
  bool? isHoatDong;
  String? lichSuBaoDuong_Id;
  String? lichSuSuaChua_Id;
  String? tenMooc;
  String? ghepNoiPhuongTien_ThietBi_Id;
  String? phuongTien_Id;
  String? phuongTien2_Id;
  String? nguoiGhep;
  String? nguoiThao;
  String? nguoiThucHien;
  String? trangThaiPT;
  String? tongChiPhi;
  String? chiPhiBD2;
  String? chiPhiSC2;
  String? vatTuThayThe;
  String? danhSachHangMuc;

  List<HangMucModel>? lichSu;

  PhuongTienModel(
      {this.id,
      this.model,
      this.ghiChu,
      this.model_Option,
      this.bienSo1,
      this.soKhung,
      this.donViSuDung,
      this.tinhTrang,
      this.loaiPT,
      this.soKM_Adsun,
      this.soKM,
      this.giaTri,
      this.model_Id,
      this.isDenHan,
      this.isYeuCau,
      this.diaDiem_Id,
      this.ngay,
      this.chiPhi_TD,
      this.ngayDiBaoDuong,
      this.ngayHoanThanh,
      this.ngayXacNhan,
      this.nguoiDiBaoDuong,
      this.nguoiXacNhan,
      this.nguoiXacNhanHoanThanh,
      this.nguoiYeuCau,
      this.nguoiPhuTrach,
      this.isDuyet,
      this.isDuyetSC,
      this.isLenhHoanThanhSC,
      this.isSuaChua,
      this.bienSo2,
      this.ketQua,
      this.noiDung,
      this.chiPhi,
      this.isBaoDuong,
      this.tenDiaDiem,
      this.hinhAnh,
      this.maNhanVien,
      this.isLenhHoanThanh,
      this.ngayDeXuatHoanThanh,
      this.nguoiDeXuatHoanThanh,
      this.lichSuBaoDuong_Id,
      this.lichSuSuaChua_Id,
      this.ngayDiSuaChua,
      this.lichSu,
      this.danhSachHangMuc,
      this.nguoiDiSuaChua,
      this.tenMooc,
      this.phuongTien2_Id,
      this.nguoiGhep,
      this.nguoiThao,
      this.phuongTien_Id,
      this.nguoiThucHien,
      this.ghepNoiPhuongTien_ThietBi_Id,
      this.isHoanThanhSC,
      this.isYeuCauSC,
      this.trangThaiPT,
      this.tongChiPhi,
      this.isHoatDong,
      this.chiPhiBD2,
      this.chiPhiSC2,
      this.vatTuThayThe,
      this.isHoanThanh});
  factory PhuongTienModel.fromJson(Map<String, dynamic> json) {
    return PhuongTienModel(
        id: json["id"].toString(),
        model: json["model"],
        model_Option: json["model_Option"],
        bienSo1: json["bienSo1"],
        soKhung: json["soKhung"],
        donViSuDung: json["donViSuDung"],
        tinhTrang: json["tinhTrang"],
        loaiPT: json["loaiPT"],
        soKM_Adsun: json["soKM_Adsun"],
        giaTri: json["giaTri"],
        isDenHan: json["isDenHan"],
        model_Id: json["model_Id"],
        isYeuCau: json["isYeuCau"],
        soKM: json["soKM"],
        ngay: json["ngay"],
        noiDung: json["noiDung"],
        ketQua: json["ketQua"],
        chiPhi_TD: json['chiPhi_TD'],
        ngayDiBaoDuong: json["ngayDiBaoDuong"],
        ngayHoanThanh: json["ngayHoanThanh"],
        ngayXacNhan: json["ngayXacNhan"],
        nguoiYeuCau: json["nguoiYeuCau"],
        nguoiXacNhan: json["nguoiXacNhan"],
        nguoiDiBaoDuong: json["nguoiDiBaoDuong"],
        nguoiXacNhanHoanThanh: json["nguoiXacNhanHoanThanh"],
        isDuyet: json["isDuyet"],
        isBaoDuong: json["isBaoDuong"],
        nguoiPhuTrach: json["nguoiPhuTrach"],
        maNhanVien: json['maNhanVien'],
        tenDiaDiem: json['tenDiaDiem'],
        chiPhi: json['chiPhi'],
        hinhAnh: json['hinhAnh'],
        lichSuBaoDuong_Id: json['lichSuBaoDuong_Id'],
        isLenhHoanThanh: json['isLenhHoanThanh'],
        ngayDeXuatHoanThanh: json['ngayDeXuatHoanThanh'],
        nguoiDeXuatHoanThanh: json['nguoiDeXuatHoanThanh'],
        ghiChu: json['ghiChu'],
        bienSo2: json['bienSo2'],
        diaDiem_Id: json['diaDiem_Id'],
        isDuyetSC: json["isDuyetSC"],
        isSuaChua: json["isSuaChua"],
        lichSuSuaChua_Id: json['lichSuSuaChua_Id'],
        isLenhHoanThanhSC: json['isLenhHoanThanhSC'],
        ngayDiSuaChua: json['ngayDiSuaChua'],
        nguoiDiSuaChua: json['nguoiDiSuaChua'],
        tenMooc: json['tenMooc'],
        ghepNoiPhuongTien_ThietBi_Id: json['ghepNoiPhuongTien_ThietBi_Id'],
        nguoiGhep: json['nguoiGhep'],
        nguoiThao: json['nguoiThao'],
        phuongTien_Id: json['phuongTien_Id'],
        danhSachHangMuc: json['danhSachHangMuc'],
        phuongTien2_Id: json['phuongTien2_Id'],
        nguoiThucHien: json['nguoiThucHien'],
        isHoanThanhSC: json['isHoanThanhSC'],
        isYeuCauSC: json['isYeuCauSC'],
        trangThaiPT: json['trangThaiPT'],
        tongChiPhi: json['tongChiPhi'],
        isHoatDong: json['isHoatDong'],
        chiPhiBD2: json['chiPhiBD2'],
        chiPhiSC2: json['chiPhiSC2'],
        vatTuThayThe: json['vatTuThayThe'],
        lichSu: (json['lichSu'] as List<dynamic>?)?.map((e) => HangMucModel.fromJson(e as Map<String, dynamic>)).toList(),
        isHoanThanh: json["isHoanThanh"]);
  }
  Map<String, dynamic> toJson() =>
      {'id': id, 'noiDung': noiDung, 'ketQua': ketQua, 'lichSuSuaChua_Id': lichSuSuaChua_Id, 'lichSuBaoDuong_Id': lichSuBaoDuong_Id, 'phuongTien_Id': phuongTien_Id, 'phuongTien2_Id': phuongTien2_Id, 'nguoiGhep': nguoiGhep, 'nguoiThao': nguoiThao, 'diaDiem_Id': diaDiem_Id, 'tenDiaDien': tenDiaDiem};
}
