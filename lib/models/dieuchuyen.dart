class DieuChuyenModel {
  String? key;
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? maKho;
  String? tenKho;
  String? tenBaiXe;
  String? maViTri;
  String? tenViTri;
  String? mauSon;
  String? soMay;
  String? lat;
  String? long;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? Kho_Id;
  String? BaiXe_Id;
  String? viTri_Id;

  DieuChuyenModel({
    this.key,
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
    this.tenBaiXe,
    this.BaiXe_Id,
    this.viTri_Id,
    this.Kho_Id,
  });
  @override
  String toString() {
    return 'DieuChuyenModel(key:$key,id: $id, soKhung: $soKhung, tenSanPham: $tenSanPham, tenMau: $tenMau, tenKho: $tenKho, soMay: $soMay, ngayXuatKhoView: $ngayNhapKhoView, tenTaiXe: $tenTaiXe, ghiChu: $ghiChu)';
  }

  factory DieuChuyenModel.fromJson(Map<String, dynamic> json) {
    return DieuChuyenModel(
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
        Kho_Id: json["Kho_Id"],
        BaiXe_Id: json["BaiXe_Id"],
        viTri_Id: json["viTri_Id"],
        tenBaiXe: json["tenBaiXe"],
        lat: json["lat"],
        long: json["long"]);
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
        "Kho_Id": Kho_Id,
        "BaiXe_Id": BaiXe_Id,
        "viTri_Id": viTri_Id,
        "tenBaiXe": tenBaiXe,
        "lat": lat,
        "long": long
      };
}
