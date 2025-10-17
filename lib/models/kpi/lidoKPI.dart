class LyDoModel {
  String? id;
  String? maLyDoKhongDanhGia;
  String? lyDoKhongDanhGia;
  String? ngayTao;
  String? nguoiTao_Id;
  String? tenNguoiTao;
  LyDoModel({
    this.id,
    this.lyDoKhongDanhGia,
    this.maLyDoKhongDanhGia,
    this.ngayTao,
    this.nguoiTao_Id,
    this.tenNguoiTao,
  });

  factory LyDoModel.fromJson(Map<String, dynamic> j) => LyDoModel(
        id: j['id'].toString(),
        maLyDoKhongDanhGia: j['maLyDoKhongDanhGia'],
        lyDoKhongDanhGia: j['lyDoKhongDanhGia'],
        ngayTao: j['ngayTao'],
        nguoiTao_Id: j['nguoiTao_Id'],
        tenNguoiTao: j['tenNguoiTao'],
      );
}
