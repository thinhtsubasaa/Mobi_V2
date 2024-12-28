class ChuyenXeModel {
  String? id;
  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? baoVeKiemTra;
  String? tenTaiXe;
  String? gioRa;
  String? ngayRaCong;
  String? noiDen;
  String? ghiChu;
  String? lyDo;
  String? hinhAnh;
  String? noiDi;
  String? bienSo;
  String? trangThaiXe;
  String? phuongThuc;
  String? donViVanChuyen;
  bool? isCheck;

  ChuyenXeModel(
      {this.id,
      this.soKhung,
      this.soMay,
      this.mauXe,
      this.baoVeKiemTra,
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
      this.isCheck,
      this.donViVanChuyen,
      this.phuongThuc,
      this.trangThaiXe});
  factory ChuyenXeModel.fromJson(Map<String, dynamic> json) {
    return ChuyenXeModel(
        id: json["id"].toString(),
        soKhung: json["soKhung"],
        soMay: json["soMay"],
        mauXe: json["mauXe"],
        baoVeKiemTra: json["baoVeKiemTra"],
        tenTaiXe: json["tenTaiXe"],
        loaiXe: json["loaiXe"],
        gioRa: json["gioRa"],
        ngayRaCong: json["ngayRaCong"],
        noiDen: json["noiDen"],
        ghiChu: json["ghiChu"],
        lyDo: json["lyDo"],
        hinhAnh: json["hinhAnh"],
        bienSo: json["bienSo"],
        isCheck: json["isCheck"],
        donViVanChuyen: json["donViVanChuyen"],
        phuongThuc: json["phuongThuc"],
        trangThaiXe: json["trangThaiXe"],
        noiDi: json["noiDi"]);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        "soKhung": soKhung,
        "soMay": soMay,
        "mauXe": mauXe,
        "baoVeKiemTra": baoVeKiemTra,
        "tenTaiXe": tenTaiXe,
        "loaiXe": loaiXe,
        "noiDi": noiDi,
        "noiDen": noiDen,
        "donViVanChuyen": donViVanChuyen,
        "phuongThuc": phuongThuc,
        "trangThaiXe": trangThaiXe,
      };
}
