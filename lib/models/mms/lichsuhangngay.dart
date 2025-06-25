class LichSuKiemTraModel {
  String? id;
  String? ghiChu;
  String? tinhTrang;
  String? phuongTien_Id;
  String? hinhAnh;

  LichSuKiemTraModel({this.id, this.ghiChu, this.hinhAnh, this.phuongTien_Id, this.tinhTrang});
  factory LichSuKiemTraModel.fromJson(Map<String, dynamic> json) {
    return LichSuKiemTraModel(id: json["id"].toString(), tinhTrang: json["tinhTrang"], ghiChu: json["ghiChu"], phuongTien_Id: json["phuongTien_Id"], hinhAnh: json["hinhAnh"]);
  }
  Map<String, dynamic> toJson() => {'id': id, 'phuongTien_Id': phuongTien_Id, 'tinhTrang': tinhTrang, 'ghiChu': ghiChu, 'hinhAnh': hinhAnh};
}
