class KeHoachGiaoXeModel {
  String? id;
  String? soKhung;
  String? nhaXeYC;
  String? nhaXeTD;
  String? bienSoYC;
  String? bienSoTD;
  String? taiXeYC;
  String? taiXeTD;
  String? trangThai;
  String? lyDo;
  String? nguoiYeuCau;
  String? nguoiXacNhan;
  String? ghiChu;
  String? kho_Id;
  String? tenTaiXe;
  String? Diadiem_Id;
  String? phuongThucVanChuyen_Id;
  String? bienSo_Id;
  String? taiXe_Id;
  String? doiTac_Id;
  String? tenDiaDiem;
  String? tenPhuongThucVanChuyen;
  String? benVanChuyen;
  String? noidi;
  String? noiden;
  String? mauXe;
  String? soXe;

  String? maSoNhanVien;
  String? keHoachGiaoXe_Id;
  String? nhaXeThayDoi_Id;
  String? phuongTienThayDoi_Id;
  String? taiXeThayDoi_Id;
  String? taiXeYeuCau_Id;
  String? nhaXeYeuCau_Id;
  String? phuongTienYeuCau_Id;
  String? ngayYeuCau;
  String? thoiGianYC;
  String? thoiGianXacNhan;
  String? ngayTao;
  String? lyDoTuChoi;

  bool? isDiGap;
  bool? isYeuCau;
  bool? isThayDoi;
  bool? isVenDer;
  bool? isUndo;

  KeHoachGiaoXeModel(
      {this.id,
      this.nhaXeYC,
      this.nhaXeTD,
      this.bienSoYC,
      this.bienSoTD,
      this.taiXeYC,
      this.soKhung,
      this.taiXeTD,
      this.trangThai,
      this.lyDo,
      this.nguoiYeuCau,
      this.nguoiXacNhan,
      this.ghiChu,
      this.tenTaiXe,
      this.noidi,
      this.noiden,
      this.isDiGap,
      this.Diadiem_Id,
      this.bienSo_Id,
      this.kho_Id,
      this.phuongThucVanChuyen_Id,
      this.taiXe_Id,
      this.tenDiaDiem,
      this.tenPhuongThucVanChuyen,
      this.benVanChuyen,
      this.soXe,
      this.mauXe,
      this.maSoNhanVien,
      this.keHoachGiaoXe_Id,
      this.nhaXeThayDoi_Id,
      this.phuongTienThayDoi_Id,
      this.nhaXeYeuCau_Id,
      this.phuongTienYeuCau_Id,
      this.ngayYeuCau,
      this.doiTac_Id,
      this.thoiGianYC,
      this.thoiGianXacNhan,
      this.lyDoTuChoi,
      this.taiXeThayDoi_Id,
      this.ngayTao,
      this.isYeuCau,
      this.isThayDoi,
      this.isVenDer,
      this.isUndo,
      this.taiXeYeuCau_Id});

  factory KeHoachGiaoXeModel.fromJson(Map<String, dynamic> json) {
    return KeHoachGiaoXeModel(
        id: json["id"],
        soKhung: json["soKhung"],
        nhaXeYC: json["nhaXeYC"],
        nhaXeTD: json["nhaXeTD"],
        bienSoTD: json["bienSoTD"],
        bienSoYC: json["bienSoYC"],
        taiXeYC: json["taiXeYC"],
        taiXeTD: json["taiXeTD"],
        trangThai: json["trangThai"],
        lyDo: json["lyDo"],
        noidi: json["noidi"],
        noiden: json["noiden"],
        nguoiYeuCau: json["nguoiYeuCau"],
        nguoiXacNhan: json["nguoiXacNhan"],
        tenTaiXe: json["tenTaiXe"],
        ghiChu: json["ghiChu"],
        taiXe_Id: json["taiXe_Id"],
        bienSo_Id: json["bienSo_Id"],
        phuongThucVanChuyen_Id: json["phuongThucVanChuyen_Id"],
        Diadiem_Id: json["Diadiem_Id"],
        kho_Id: json["kho_Id"],
        tenDiaDiem: json["tenDiaDiem"],
        tenPhuongThucVanChuyen: json["tenPhuongThucVanChuyen"],
        benVanChuyen: json["benVanChuyen"],
        soXe: json["soXe"],
        mauXe: json["mauXe"],
        maSoNhanVien: json["maSoNhanVien"],
        keHoachGiaoXe_Id: json["keHoachGiaoXe_Id"],
        nhaXeThayDoi_Id: json["nhaXeThayDoi_Id"],
        phuongTienThayDoi_Id: json["phuongTienThayDoi_Id"],
        taiXeThayDoi_Id: json["taiXeThayDoi_Id"],
        ngayYeuCau: json["ngayYeuCau"],
        doiTac_Id: json["doiTac_Id"],
        thoiGianXacNhan: json["thoiGianXacNhan"],
        lyDoTuChoi: json["lyDoTuChoi"],
        taiXeYeuCau_Id: json["taiXeYeuCau_Id"],
        nhaXeYeuCau_Id: json["nhaXeYeuCau_Id"],
        phuongTienYeuCau_Id: json["phuongTienYeuCau_Id"],
        isYeuCau: json["isYeuCau"],
        isThayDoi: json["isThayDoi"],
        isVenDer: json["isVenDer"],
        isDiGap: json["isDiGap"],
        ngayTao: json["ngayTao"],
        isUndo: json["isUndo"],
        thoiGianYC: json["thoiGianYC"]);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'soKhung': soKhung,
        'nhaXeYC': nhaXeYC,
        'nhaXeTD': nhaXeTD,
        'bienSoYC': bienSoYC,
        'bienSoTD': bienSoTD,
        'taiXeYC': taiXeYC,
        'taiXeTD': taiXeTD,
        'trangThai': trangThai,
        'lyDo': lyDo,
        'noidi': noidi,
        'noiden': noiden,
        'nguoiYeuCau': nguoiYeuCau,
        'keHoachGiaoXe_Id': keHoachGiaoXe_Id,
        'nhaXeThayDoi_Id': nhaXeThayDoi_Id,
        'phuongTienThayDoi_Id': phuongTienThayDoi_Id,
        'taiXeThayDoi_Id': taiXeThayDoi_Id,
        "kho_Id": kho_Id,
        "Diadiem_Id": Diadiem_Id,
        "phuongThucVanChuyen_Id": phuongThucVanChuyen_Id,
        "bienSo_Id": bienSo_Id,
        "taiXe_Id": taiXe_Id,
        "tenDiaDiem": tenDiaDiem,
        "tenPhuongThucVanChuyen": tenPhuongThucVanChuyen,
        "benVanChuyen": benVanChuyen,
        "soXe": soXe,
        "maSoNhanVien": maSoNhanVien,
        "ngayYeuCau": ngayYeuCau,
        "doiTac_Id": doiTac_Id,
        "taiXeYeuCau_Id": taiXeYeuCau_Id,
        "nhaXeYeuCau_Id": nhaXeYeuCau_Id,
        "phuongTienYeuCau_Id": phuongTienYeuCau_Id,
      };
}
