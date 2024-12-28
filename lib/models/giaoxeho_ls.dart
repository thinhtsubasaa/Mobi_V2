class GiaoXeHoLSModel {
  String? id;
  String? soKhung;
  String? trangThai;
  String? lyDo;
  String? nguoiYeuCau;
  String? nguoiXacNhan;
  String? noiGiao;
  String? mauXe;
  String? ngayYeuCau;
  String? ngayXacNhan;
  String? thoiGianYC;
  String? thoiGianXacNhan;
  String? ngayTao;
  String? lyDoTuChoi;
  String? taiXe_Id;
  String? khoDen_Id;
  String? diaDiem_Id;
  String? ngayXuatKho;
  String? ngayGiaoXe;
  String? benVanChuyen;
  String? taiXe;
  bool? isYeuCau;
  bool? isKeHoach;
  bool? isVenDer;
  bool? isLock;
  bool? isUndo;

  GiaoXeHoLSModel({
    this.id,
    this.soKhung,
    this.trangThai,
    this.lyDo,
    this.noiGiao,
    this.nguoiYeuCau,
    this.nguoiXacNhan,
    this.mauXe,
    this.taiXe_Id,
    this.khoDen_Id,
    this.diaDiem_Id,
    this.ngayXuatKho,
    this.ngayYeuCau,
    this.thoiGianYC,
    this.taiXe,
    this.thoiGianXacNhan,
    this.lyDoTuChoi,
    this.isKeHoach,
    this.ngayGiaoXe,
    this.ngayTao,
    this.benVanChuyen,
    this.isYeuCau,
    this.isVenDer,
    this.ngayXacNhan,
    this.isLock,
    this.isUndo,
  });

  factory GiaoXeHoLSModel.fromJson(Map<String, dynamic> json) {
    return GiaoXeHoLSModel(
        id: json["id"],
        soKhung: json["soKhung"],
        trangThai: json["trangThai"],
        lyDo: json["lyDo"],
        nguoiYeuCau: json["nguoiYeuCau"],
        nguoiXacNhan: json["nguoiXacNhan"],
        mauXe: json["mauXe"],
        ngayYeuCau: json["ngayYeuCau"],
        thoiGianXacNhan: json["thoiGianXacNhan"],
        lyDoTuChoi: json["lyDoTuChoi"],
        isYeuCau: json["isYeuCau"],
        isKeHoach: json["isKeHoach"],
        noiGiao: json["noiGiao"],
        ngayTao: json["ngayTao"],
        ngayGiaoXe: json["ngayGiaoXe"],
        ngayXacNhan: json["ngayXacNhan"],
        ngayXuatKho: json["ngayXuatKho"],
        taiXe_Id: json["taiXe_Id"],
        khoDen_Id: json["khoDen_Id"],
        diaDiem_Id: json["diaDiem_Id"],
        isVenDer: json["isVenDer"],
        benVanChuyen: json["benVanChuyen"],
        isLock: json["isLock"],
        taiXe: json["taiXe"],
        isUndo: json["isUndo"],
        thoiGianYC: json["thoiGianYC"]);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'soKhung': soKhung,
        'trangThai': trangThai,
        'lyDo': lyDo,
        'nguoiYeuCau': nguoiYeuCau,
        "ngayYeuCau": ngayYeuCau,
        "ngayXuatkho": ngayXuatKho,
        "taiXe_Id": taiXe_Id,
        "khoDen_Id": khoDen_Id,
        "diaDiem_Id": diaDiem_Id,
      };
}
