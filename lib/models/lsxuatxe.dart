class LSXuatXeModel {
  String? id;
  String? ngay;
  String? thongtinvanchuyen;
  String? thongTinChiTiet;
  String? toaDo;

  LSXuatXeModel(
      {this.id,
      this.ngay,
      this.thongtinvanchuyen,
      this.thongTinChiTiet,
      this.toaDo});
  factory LSXuatXeModel.fromJson(Map<String, dynamic> json) {
    return LSXuatXeModel(
      id: json["id"].toString(),
      ngay: json["ngay"],
      thongtinvanchuyen: json["thongtinvanchuyen"],
      thongTinChiTiet: json["thongTinChiTiet"],
      toaDo: json["toaDo"],
    );
  }
}
