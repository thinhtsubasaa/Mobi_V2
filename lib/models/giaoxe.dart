class GiaoXeModel {
  String? key;
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? maKho;
  String? tenKho;
  String? maViTri;
  String? tenViTri;
  String? mauSon;
  String? soMay;
  String? lat;
  String? long;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? kho_Id;
  String? Diadiem_Id;
  String? phuongThucVanChuyen_Id;
  String? loaiPhuongTien_Id;
  String? danhSachPhuongTien_Id;
  String? bienSo_Id;
  String? taiXe_Id;
  String? nguoiNhan;
  List<FileDinhKems>? fileDinhKems;

  GiaoXeModel(
      {this.key,
      this.id,
      this.maMau,
      this.mauSon,
      this.maViTri,
      this.tenViTri,
      this.maSanPham,
      this.lat,
      this.long,
      this.soKhung,
      this.tenSanPham,
      this.tenMau,
      this.tenKho,
      this.soMay,
      this.ngayNhapKhoView,
      this.tenTaiXe,
      this.ghiChu,
      this.maKho,
      this.Diadiem_Id,
      this.bienSo_Id,
      this.danhSachPhuongTien_Id,
      this.kho_Id,
      this.loaiPhuongTien_Id,
      this.phuongThucVanChuyen_Id,
      this.taiXe_Id,
      this.nguoiNhan,
      this.fileDinhKems});
  @override
  String toString() {
    return 'GiaoXeModel(key:$key,id: $id, soKhung: $soKhung, tenSanPham: $tenSanPham, tenMau: $tenMau, tenKho: $tenKho, soMay: $soMay, ngayXuatKhoView: $ngayNhapKhoView, tenTaiXe: $tenTaiXe, ghiChu: $ghiChu, fileDinhKems: $fileDinhKems)';
  }

  factory GiaoXeModel.fromJson(Map<String, dynamic> json) {
    return GiaoXeModel(
      key: json["key"],
      id: json["id"],
      soKhung: json["soKhung"],
      maSanPham: json["maSanPham"],
      tenSanPham: json["tenSanPham"],
      soMay: json["soMay"],
      maMau: json["maMau"],
      tenMau: json["tenMau"],
      tenKho: json["tenKho"],
      maViTri: json["maViTri"],
      tenViTri: json["tenViTr"],
      mauSon: json["mauSon"],
      ngayNhapKhoView: json["ngayNhapKhoView"],
      tenTaiXe: json["tenTaiXe"],
      ghiChu: json["ghiChu"],
      maKho: json["maKho"],
      taiXe_Id: json["taiXe_Id"],
      bienSo_Id: json["bienSo_Id"],
      danhSachPhuongTien_Id: json["danhSachPhuongTien_Id"],
      loaiPhuongTien_Id: json["loaiPhuongTien_Id"],
      phuongThucVanChuyen_Id: json["phuongThucVanChuyen_Id"],
      Diadiem_Id: json["Diadiem_Id"],
      kho_Id: json["kho_Id"],
      lat: json["lat"],
      long: json["long"],
      nguoiNhan: json["nguoiNhan"],
      fileDinhKems: (json['phuKien'] as List)
          .map((e) => FileDinhKems.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'soKhung': soKhung,
        'maSanPham': maSanPham,
        'tenSanPham': tenSanPham,
        'soMay': soMay,
        'maMau': maMau,
        'tenMau': tenMau,
        'tenKho': tenKho,
        'maViTri': maViTri,
        'tenViTri': tenViTri,
        'mauSon': mauSon,
        'ngayNhapKhoView': ngayNhapKhoView,
        "maKho": maKho,
        "kho_Id": kho_Id,
        "Diadiem_Id": Diadiem_Id,
        "phuongThucVanChuyen_Id": phuongThucVanChuyen_Id,
        "loaiPhuongTien_Id": loaiPhuongTien_Id,
        "danhSachPhuongTien_Id": danhSachPhuongTien_Id,
        "bienSo_Id": bienSo_Id,
        "taiXe_Id": taiXe_Id,
        "lat": lat,
        "long": long,
        "nguoiNhan": nguoiNhan,
      };
}

class FileDinhKems {
  String? fileName;
  String? fileLink;
  String? fileData;
  String? name;
  String? url;

  FileDinhKems(
      {this.fileName, this.fileLink, this.fileData, this.name, this.url});

  @override
  String toString() {
    return 'GiaoXeModel(fileName: $fileName)';
  }

  factory FileDinhKems.fromJson(Map<String, dynamic> json) {
    return FileDinhKems(
        fileName: json['fileName'],
        fileLink: json['fileLink'],
        fileData: json['fileData'],
        name: json['name'],
        url: json['url']);
  }
}