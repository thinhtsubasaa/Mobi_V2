class VehicleInfo {
  String? plate;
  String? toaDo;
  String? km;
  String? groupName;
  String? speed;
  String? address;
  String? angle;
  String? taiXePhuTrach;
  String? model;
  String? model_Option;
  String? soKM_Adsun;
  String? loaiPT;
  String? ngayBaoDuong;
  String? hinhAnh_TaiXe;
  String? maNhanVien;
  String? soKM;
  String? soKMTuNgayBaoDuong;
  String? soKM_NgayBaoDuong;

  VehicleInfo({
    this.plate,
    this.toaDo,
    this.km,
    this.groupName,
    this.speed,
    this.address,
    this.angle,
    this.loaiPT,
    this.model,
    this.model_Option,
    this.ngayBaoDuong,
    this.soKM_Adsun,
    this.taiXePhuTrach,
    this.hinhAnh_TaiXe,
    this.maNhanVien,
    this.soKM,
    this.soKMTuNgayBaoDuong,
    this.soKM_NgayBaoDuong,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
        plate: json['plate'],
        toaDo: json['toaDo'],
        km: json['km'],
        groupName: json['truck'],
        speed: json['speed'],
        address: json['address'],
        angle: json['angle'],
        loaiPT: json['loaiPT'],
        model: json['model'],
        model_Option: json['model_Option'],
        ngayBaoDuong: json['ngayBaoDuong'],
        soKM_Adsun: json['soKM_Adsun'],
        hinhAnh_TaiXe: json["hinhAnh_TaiXe"],
        maNhanVien: json['maNhanVien'],
        soKM: json['soKM'],
        soKMTuNgayBaoDuong: json['soKMTuNgayBaoDuong'],
        soKM_NgayBaoDuong: json['soKM_NgayBaoDuong'],
        taiXePhuTrach: json['taiXePhuTrach']);
  }
}
