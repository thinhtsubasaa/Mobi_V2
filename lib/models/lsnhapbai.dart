class LSNhapBaiModel {
  String? id;
  String? ngay;
  String? thongTinChiTiet;
  String? toaDo;

  LSNhapBaiModel({
    this.id,
    this.ngay,
    this.thongTinChiTiet,
    this.toaDo,
  });
  factory LSNhapBaiModel.fromJson(Map<String, dynamic> json) {
    return LSNhapBaiModel(
      id: json["id"].toString(),
      ngay: json["ngay"],
      thongTinChiTiet: json["thongTinChiTiet"],
      toaDo: json["toaDo"],
    );
  }
}
