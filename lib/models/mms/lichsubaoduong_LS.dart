class LichSuBaoDuongLSModel {
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
  String? lyDo;
  bool? isYeuCau;
  bool? isThayDoi;
  bool? isVenDer;

  LichSuBaoDuongLSModel(
      {this.id,
      this.tenDiaDiem,
      this.ngay,
      this.trangThai,
      this.loaiBaoDuong,
      this.tanSuat,
      this.giaTri,
      this.lyDo,
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
      this.nguoiXacNhan});
  factory LichSuBaoDuongLSModel.fromJson(Map<String, dynamic> json) {
    return LichSuBaoDuongLSModel(
        id: json["id"].toString(),
        tenDiaDiem: json["tenDiaDiem"],
        ngay: json["ngay"],
        loaiBaoDuong: json["loaiBaoDuong"],
        tanSuat: json["tanSuat"],
        giaTri: json["giaTri"],
        bienSo1: json["bienSo1"],
        soKM: json["soKM"],
        lyDo: json["lyDo"],
        trangThai: json["trangThai"],
        soChuyenXe: json["soChuyenXe"],
        chiSo: json["chiSo"],
        chiPhi: json["chiPhi"],
        phuongTien_Id: json["phuongTien_Id"],
        ketQua: json["ketQua"],
        baoDuong_Id: json["baoDuong_Id"],
        model: json["model"],
        model_Option: json["model_Option"],
        soKM_Adsun: json["soKM_Adsun"],
        nguoiYeuCau: json["nguoiYeuCau"],
        nguoiXacNhan: json["nguoiXacNhan"],
        ngayXacNhan: json["ngayXacNhan"],
        noiDung: json["noiDung"]);
  }
  Map<String, dynamic> toJson() => {'id': id, 'phuongTien_Id': phuongTien_Id, 'baoDuong_Id': baoDuong_Id, 'trangThai': trangThai, 'lyDo': lyDo};
}
