class LichSuBaoDuongNewModel {
  String? id;
  String? tenDiaDiem;
  String? ngay;
  String? ngayXacNhan;
  String? loaiBaoDuong;
  String? tanSuat;
  String? giaTri;
  String? bienSo1;
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

  String? nguoiDiBaoDuong;
  String? nguoiXacNhanHoanThanh;

  bool? isDuyet;
  bool? isBaoDuong;
  bool? isHoanThanh;
  String? diaDiem_Id;

  LichSuBaoDuongNewModel({
    this.id,
    this.tenDiaDiem,
    this.ngay,
    this.trangThai,
    this.loaiBaoDuong,
    this.tanSuat,
    this.giaTri,
    this.bienSo1,
    this.soKM,
    this.soChuyenXe,
    this.chiSo,
    this.chiPhi,
    this.soKM_Adsun,
    this.ketQua,
    this.noiDung,
    this.model,
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
    this.nguoiDiBaoDuong,
    this.diaDiem_Id,
    this.tinhTrang,
    this.nguoiXacNhanHoanThanh,
  });
  factory LichSuBaoDuongNewModel.fromJson(Map<String, dynamic> json) {
    return LichSuBaoDuongNewModel(
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
        tinhTrang: json["tinhTrang"],
        isYeuCau: json["isYeuCau"],
        diaDiem_Id: json["diaDiem_Id"],
        isHoanThanh: json["isHoanThanh"]);
  }
  Map<String, dynamic> toJson() => {'id': id, 'phuongTien_Id': phuongTien_Id, 'baoDuong_Id': baoDuong_Id, 'trangThai': trangThai, 'noiDung': noiDung, 'ketQua': ketQua, 'hinhAnh': hinhAnh, 'diaDiem_Id': diaDiem_Id, 'ngayDiBaoDuong': ngayDiBaoDuong};
}
