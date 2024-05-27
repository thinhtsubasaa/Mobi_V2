class LSNhapBaiModel {
  String? id;
  String? kho;
  String? baiXe;
  String? thoiGianVao;
  String? thoiGianRa;
  String? soNgay;
  String? ngayVao;
  String? toaDo;
  String? ngayRa;

  LSNhapBaiModel({
    this.id,
    this.baiXe,
    this.kho,
    this.ngayRa,
    this.ngayVao,
    this.toaDo,
    this.soNgay,
    this.thoiGianRa,
    this.thoiGianVao,
  });
  factory LSNhapBaiModel.fromJson(Map<String, dynamic> json) {
    return LSNhapBaiModel(
      id: json["id"].toString(),
      kho: json["kho"],
      baiXe: json["baiXe"],
      thoiGianVao: json["thoiGianVao"],
      thoiGianRa: json["thoiGianRa"],
      soNgay: json["soNgay"],
      ngayVao: json["ngayVao"],
      ngayRa: json["ngayRa"],
      toaDo: json["toaDo"],
    );
  }
}
