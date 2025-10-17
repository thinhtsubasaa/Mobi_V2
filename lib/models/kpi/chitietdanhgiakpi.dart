class ChiTietDanhGiaKPIModel {
  final String? nguoiDuyetDanhGia1_Id;
  final String? nguoiDuyetDanhGia2_Id;
  final String? nguoiDuyetDanhGia3_Id;
  final String? nguoiDuyetDanhGia4_Id;
  final String? nguoiDuyetDanhGia5_Id;
  final String? tenNguoiDuyet1;
  final String? maNguoiDuyet1;
  final String? tenNguoiDuyet2;
  final String? maNguoiDuyet2;
  final String? tenNguoiDuyet3;
  final String? maNguoiDuyet3;
  final String? maNguoiDuyet4;
  final String? maNguoiDuyet5;
  final String? tenNguoiDuyet4;
  final String? tenNguoiDuyet5;
  final String? nhanXetDanhGia1;
  final String? nhanXetDanhGia2;
  final String? nhanXetDanhGia3;
  final String? nhanXetDanhGia4;
  final String? nhanXetDanhGia5;
  bool? isDaXem;
  bool? isDuocPhepDanhDauDaXem;
  bool? isKhongDanhGia;
  bool? isHoanThanh;
  bool? isThucHienChinhSuaCVKPI;
  String? vptq_kpi_LyDoKhongDanhGia_Id;
  String? lyDoKhongDanhGia;
  String? maLyDoKhongDanhGia;
  bool? isThucHienDanhGiaLanhDao;
  bool? isUyQuyen;
  String? id;
  bool? isLanhDaoTiemNang;
  bool? isLanhDaoDonVi;
  String? nhiemVu;
  String? chucDanh_Id;
  String? tenChucDanh;
  String? chucVu_Id;
  String? tenChucVu;
  String? phongBanThaco_Id;
  String? maPhongBan;
  String? tenPhongBan;
  String? vptq_kpi_DonViKPI_Id;
  String? maDonViKPI;
  String? tenDonViKPI;
  String? vptq_kpi_KyDanhGiaKPI_Id;
  int? chuKy;
  bool? isDongDanhGia;
  bool? isHoanThanhDanhGia;
  double? diemKetQuaCuoiCung;
  bool? isTraLaiDanhGia;
  String? ngayTao;
  String? thoiGianHoanThanh;
  String? nguoiTao_Id;
  String? tenNguoiTao;
  String? user_Id;
  String? tenUser;
  String? maUser;
  String? nguoiDuyetDanhGiaHienTai_Id;
  String? tenNguoiDuyetHienTai;
  String? maNguoiDuyetHienTai;
  int? viTriDuyetDanhGia;
  int? viTriDuyet;
  double? diemCong;
  double? diemKetQua;
  double? diemKetQuaTamThoi;
  double? diemKetQuaTuDanhGia;
  double? diemTru;
  String? thoiDiem;
  int? thang;
  int? nam;
  int? kyQuy;
  int? trangThai;
  bool? isThucHienDuyetKPICVDV;
  bool? isThucHienDanhGia;

  List<KiemNhiemModel>? kiemNhiems;
  List<NhomPIModel>? nhomPIs;
  List<ThangDiemXepLoaiChiTietModel>? thangDiemXepLoaiChiTiets;
  String? xepLoai;

  ChiTietDanhGiaKPIModel({
    this.nguoiDuyetDanhGia1_Id,
    this.nguoiDuyetDanhGia2_Id,
    this.nguoiDuyetDanhGia3_Id,
    this.nguoiDuyetDanhGia4_Id,
    this.nguoiDuyetDanhGia5_Id,
    this.maNguoiDuyet1,
    this.tenNguoiDuyet1,
    this.maNguoiDuyet2,
    this.tenNguoiDuyet2,
    this.maNguoiDuyet3,
    this.tenNguoiDuyet3,
    this.maNguoiDuyet4,
    this.tenNguoiDuyet4,
    this.maNguoiDuyet5,
    this.tenNguoiDuyet5,
    this.nhanXetDanhGia1,
    this.nhanXetDanhGia2,
    this.nhanXetDanhGia3,
    this.nhanXetDanhGia4,
    this.nhanXetDanhGia5,
    this.isDaXem,
    this.isDuocPhepDanhDauDaXem,
    this.isKhongDanhGia,
    this.isHoanThanh,
    this.isThucHienChinhSuaCVKPI,
    this.vptq_kpi_LyDoKhongDanhGia_Id,
    this.lyDoKhongDanhGia,
    this.maLyDoKhongDanhGia,
    this.isThucHienDanhGiaLanhDao,
    this.isUyQuyen,
    this.id,
    this.isLanhDaoTiemNang,
    this.isLanhDaoDonVi,
    this.nhiemVu,
    this.chucDanh_Id,
    this.tenChucDanh,
    this.chucVu_Id,
    this.tenChucVu,
    this.phongBanThaco_Id,
    this.maPhongBan,
    this.tenPhongBan,
    this.vptq_kpi_DonViKPI_Id,
    this.maDonViKPI,
    this.tenDonViKPI,
    this.vptq_kpi_KyDanhGiaKPI_Id,
    this.chuKy,
    this.isDongDanhGia,
    this.isHoanThanhDanhGia,
    this.diemKetQuaCuoiCung,
    this.isTraLaiDanhGia,
    this.ngayTao,
    this.thoiGianHoanThanh,
    this.nguoiTao_Id,
    this.tenNguoiTao,
    this.user_Id,
    this.tenUser,
    this.maUser,
    this.nguoiDuyetDanhGiaHienTai_Id,
    this.tenNguoiDuyetHienTai,
    this.maNguoiDuyetHienTai,
    this.viTriDuyetDanhGia,
    this.viTriDuyet,
    this.diemCong,
    this.diemKetQua,
    this.diemKetQuaTamThoi,
    this.diemKetQuaTuDanhGia,
    this.diemTru,
    this.thoiDiem,
    this.thang,
    this.nam,
    this.kyQuy,
    this.trangThai,
    this.isThucHienDuyetKPICVDV,
    this.isThucHienDanhGia,
    this.kiemNhiems,
    this.thangDiemXepLoaiChiTiets,
    this.xepLoai,
    this.nhomPIs,
  });

  factory ChiTietDanhGiaKPIModel.fromJson(Map<String, dynamic> json) {
    return ChiTietDanhGiaKPIModel(
      nguoiDuyetDanhGia1_Id: json['nguoiDuyetDanhGia1_Id']?.toString(),
      nguoiDuyetDanhGia2_Id: json['nguoiDuyetDanhGia2_Id']?.toString(),
      nguoiDuyetDanhGia3_Id: json['nguoiDuyetDanhGia3_Id']?.toString(),
      nguoiDuyetDanhGia4_Id: json['nguoiDuyetDanhGia4_Id']?.toString(),
      nguoiDuyetDanhGia5_Id: json['nguoiDuyetDanhGia5_Id']?.toString(),
      nhanXetDanhGia1: json['nhanXetDanhGia1'],
      nhanXetDanhGia2: json['nhanXetDanhGia2'],
      nhanXetDanhGia3: json['nhanXetDanhGia3'],
      nhanXetDanhGia4: json['nhanXetDanhGia4'],
      nhanXetDanhGia5: json['nhanXetDanhGia5'],
      tenNguoiDuyet1: json['tenNguoiDuyet1'],
      maNguoiDuyet1: json['maNguoiDuyet1'],
      tenNguoiDuyet2: json['tenNguoiDuyet2'],
      maNguoiDuyet2: json['maNguoiDuyet2'],
      tenNguoiDuyet3: json['tenNguoiDuyet3'],
      maNguoiDuyet3: json['maNguoiDuyet3'],
      tenNguoiDuyet4: json['tenNguoiDuyet4'],
      maNguoiDuyet4: json['maNguoiDuyet4'],
      tenNguoiDuyet5: json['tenNguoiDuyet5'],
      maNguoiDuyet5: json['maNguoiDuyet5'],
      isDaXem: json["isDaXem"],
      isDuocPhepDanhDauDaXem: json["isDuocPhepDanhDauDaXem"],
      isKhongDanhGia: json["isKhongDanhGia"],
      id: json["id"],
      nhiemVu: json["nhiemVu"],
      tenChucDanh: json["tenChucDanh"],
      tenChucVu: json["tenChucVu"],
      tenPhongBan: json["tenPhongBan"],
      tenDonViKPI: json["tenDonViKPI"],
      chuKy: json["chuKy"],
      isDongDanhGia: json["isDongDanhGia"],
      isHoanThanhDanhGia: json["isHoanThanhDanhGia"],
      diemKetQuaCuoiCung: (json["diemKetQuaCuoiCung"] as num?)?.toDouble(),
      diemKetQuaTamThoi: (json["diemKetQuaTamThoi"] as num?)?.toDouble(),
      diemKetQuaTuDanhGia: (json["diemKetQuaTuDanhGia"] as num?)?.toDouble(),
      diemTru: (json["diemTru"] as num?)?.toDouble(),
      thang: json["thang"],
      nam: json["nam"],
      tenNguoiDuyetHienTai: json["tenNguoiDuyetHienTai"],
      maNguoiDuyetHienTai: json["maNguoiDuyetHienTai"],
      viTriDuyetDanhGia: json["viTriDuyetDanhGia"],
      viTriDuyet: json["viTriDuyet"],
      diemCong: (json["diemCong"] as num?)?.toDouble(),
      diemKetQua: (json["diemKetQua"] as num?)?.toDouble(),
      thoiDiem: json["thoiDiem"],
      kyQuy: json["kyQuy"],
      tenNguoiTao: json["tenNguoiTao"],
      maUser: json["maUser"],
      tenUser: json["tenUser"],
      nguoiTao_Id: json["nguoiTao_Id"],
      user_Id: json["user_Id"],
      nguoiDuyetDanhGiaHienTai_Id: json["nguoiDuyetDanhGiaHienTai_Id"],
      vptq_kpi_KyDanhGiaKPI_Id: json["vptq_kpi_KyDanhGiaKPI_Id"],
      vptq_kpi_DonViKPI_Id: json["vptq_kpi_DonViKPI_Id"],
      maDonViKPI: json["maDonViKPI"],
      vptq_kpi_LyDoKhongDanhGia_Id: json["vptq_kpi_LyDoKhongDanhGia_Id"],
      lyDoKhongDanhGia: json["lyDoKhongDanhGia"],
      maLyDoKhongDanhGia: json["maLyDoKhongDanhGia"],
      isThucHienDanhGiaLanhDao: json["isThucHienDanhGiaLanhDao"],
      isUyQuyen: json["isUyQuyen"],
      chucDanh_Id: json["chucDanh_Id"],
      chucVu_Id: json["chucVu_Id"],
      phongBanThaco_Id: json["phongBanThaco_Id"],
      maPhongBan: json["maPhongBan"],
      ngayTao: json["ngayTao"],
      thoiGianHoanThanh: json["thoiGianHoanThanh"],
      isTraLaiDanhGia: json["isTraLaiDanhGia"],
      isThucHienDuyetKPICVDV: json["isThucHienDuyetKPICVDV"],
      isThucHienDanhGia: json["isThucHienDanhGia"],
      isHoanThanh: json['isHoanThanh'],
      isThucHienChinhSuaCVKPI: json['isThucHienChinhSuaCVKPI'],
      trangThai: json["trangThai"],
      xepLoai: json["xepLoai"],
      kiemNhiems: (json["kiemNhiems"] as List?)?.map((e) => KiemNhiemModel.fromJson(e)).toList(),
      nhomPIs: (json["nhomPIs"] as List?)?.map((e) => NhomPIModel.fromJson(e)).toList(),
      thangDiemXepLoaiChiTiets: (json["thangDiemXepLoaiChiTiets"] as List?)?.map((e) => ThangDiemXepLoaiChiTietModel.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'nguoiDuyetDanhGia1_Id': nguoiDuyetDanhGia1_Id,
        'nguoiDuyetDanhGia2_Id': nguoiDuyetDanhGia2_Id,
        'nguoiDuyetDanhGia3_Id': nguoiDuyetDanhGia3_Id,
        'nguoiDuyetDanhGia4_Id': nguoiDuyetDanhGia4_Id,
        'nguoiDuyetDanhGia5_Id': nguoiDuyetDanhGia5_Id,
        'maNguoiDuyet1': maNguoiDuyet1,
        'tenNguoiDuyet1': tenNguoiDuyet1,
        'nhanXetDanhGia1': nhanXetDanhGia1,
        'maNguoiDuyet2': maNguoiDuyet2,
        'tenNguoiDuyet2': tenNguoiDuyet2,
        'nhanXetDanhGia2': nhanXetDanhGia2,
        'maNguoiDuyet3': maNguoiDuyet3,
        'tenNguoiDuyet3': tenNguoiDuyet3,
        'nhanXetDanhGia3': nhanXetDanhGia3,
        'maNguoiDuyet4': maNguoiDuyet4,
        'tenNguoiDuyet4': tenNguoiDuyet4,
        'nhanXetDanhGia4': nhanXetDanhGia4,
        'maNguoiDuyet5': maNguoiDuyet5,
        'tenNguoiDuyet5': tenNguoiDuyet5,
        'nhanXetDanhGia5': nhanXetDanhGia5,
        "isDaXem": isDaXem,
        "isDuocPhepDanhDauDaXem": isDuocPhepDanhDauDaXem,
        "isHoanThanh": isHoanThanh,
        "isThucHienChinhSuaCVKPI": isThucHienChinhSuaCVKPI,
        "isKhongDanhGia": isKhongDanhGia,
        "vptq_kpi_LyDoKhongDanhGia_Id": vptq_kpi_LyDoKhongDanhGia_Id,
        "lyDoKhongDanhGia": lyDoKhongDanhGia,
        "maLyDoKhongDanhGia": maLyDoKhongDanhGia,
        "isThucHienDanhGiaLanhDao": isThucHienDanhGiaLanhDao,
        "isUyQuyen": isUyQuyen,
        "id": id,
        "isLanhDaoTiemNang": isLanhDaoTiemNang,
        "isLanhDaoDonVi": isLanhDaoDonVi,
        "nhiemVu": nhiemVu,
        "chucDanh_Id": chucDanh_Id,
        "tenChucDanh": tenChucDanh,
        "chucVu_Id": chucVu_Id,
        "tenChucVu": tenChucVu,
        "phongBanThaco_Id": phongBanThaco_Id,
        "maPhongBan": maPhongBan,
        "tenPhongBan": tenPhongBan,
        "vptq_kpi_DonViKPI_Id": vptq_kpi_DonViKPI_Id,
        "maDonViKPI": maDonViKPI,
        "tenDonViKPI": tenDonViKPI,
        "vptq_kpi_KyDanhGiaKPI_Id": vptq_kpi_KyDanhGiaKPI_Id,
        "chuKy": chuKy,
        "isDongDanhGia": isDongDanhGia,
        "isHoanThanhDanhGia": isHoanThanhDanhGia,
        "diemKetQuaCuoiCung": diemKetQuaCuoiCung,
        "isTraLaiDanhGia": isTraLaiDanhGia,
        "ngayTao": ngayTao,
        "thoiGianHoanThanh": thoiGianHoanThanh,
        "nguoiTao_Id": nguoiTao_Id,
        "tenNguoiTao": tenNguoiTao,
        "user_Id": user_Id,
        "tenUser": tenUser,
        "maUser": maUser,
        "nguoiDuyetDanhGiaHienTai_Id": nguoiDuyetDanhGiaHienTai_Id,
        "tenNguoiDuyetHienTai": tenNguoiDuyetHienTai,
        "maNguoiDuyetHienTai": maNguoiDuyetHienTai,
        "viTriDuyetDanhGia": viTriDuyetDanhGia,
        "diemCong": diemCong,
        "diemKetQua": diemKetQua,
        "diemKetQuaTamThoi": diemKetQuaTamThoi,
        "diemKetQuaTuDanhGia": diemKetQuaTuDanhGia,
        "diemTru": diemTru,
        "thoiDiem": thoiDiem,
        "thang": thang,
        "nam": nam,
        "kyQuy": kyQuy,
        "trangThai": trangThai,
        "isThucHienDuyetKPICVDV": isThucHienDuyetKPICVDV,
        "isThucHienDanhGia": isThucHienDanhGia,
        "kiemNhiems": kiemNhiems?.map((e) => e.toJson()).toList(),
        "thangDiemXepLoaiChiTiets": thangDiemXepLoaiChiTiets?.map((e) => e.toJson()).toList(),
      };
}

class KiemNhiemModel {
  String? vptq_kpi_KPICaNhanKiemNhiem_Id;
  String? vptq_kpi_DonViKPI_Id;
  String? chucVu_Id;
  String? chucDanh_Id;
  String? nhiemVu;
  String? tenDonViKPI;
  String? tenPhongBan;
  String? tenChucDanh;
  String? tenChucVu;
  int? tyTrong;
  double? diemTuDanhGia;
  double? diemLanhDao;
  List<NhomPIModel>? nhomPIs;
  List<NhomPIModel>? kpiCaNhanNhomPIs;

  KiemNhiemModel({
    this.vptq_kpi_KPICaNhanKiemNhiem_Id,
    this.vptq_kpi_DonViKPI_Id,
    this.chucVu_Id,
    this.chucDanh_Id,
    this.nhiemVu,
    this.tenDonViKPI,
    this.tenPhongBan,
    this.tenChucDanh,
    this.tenChucVu,
    this.tyTrong,
    this.diemTuDanhGia,
    this.diemLanhDao,
    this.nhomPIs,
    this.kpiCaNhanNhomPIs,
  });

  factory KiemNhiemModel.fromJson(Map<String, dynamic> json) {
    return KiemNhiemModel(
      vptq_kpi_KPICaNhanKiemNhiem_Id: json["vptq_kpi_KPICaNhanKiemNhiem_Id"],
      vptq_kpi_DonViKPI_Id: json["vptq_kpi_DonViKPI_Id"],
      chucVu_Id: json["chucVu_Id"],
      chucDanh_Id: json["chucDanh_Id"],
      nhiemVu: json["nhiemVu"],
      tenDonViKPI: json["tenDonViKPI"],
      tenPhongBan: json["tenPhongBan"],
      tenChucDanh: json["tenChucDanh"],
      tenChucVu: json["tenChucVu"],
      tyTrong: json["tyTrong"],
      diemTuDanhGia: (json["diemTuDanhGia"] as num?)?.toDouble(),
      diemLanhDao: (json["diemLanhDao"] as num?)?.toDouble(),
      nhomPIs: (json["nhomPIs"] as List?)?.map((e) => NhomPIModel.fromJson(e)).toList(),
      kpiCaNhanNhomPIs: (json['kpiCaNhanNhomPIs'] as List?)?.map((e) => NhomPIModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        "vptq_kpi_KPICaNhanKiemNhiem_Id": vptq_kpi_KPICaNhanKiemNhiem_Id,
        "vptq_kpi_DonViKPI_Id": vptq_kpi_DonViKPI_Id,
        "chucVu_Id": chucVu_Id,
        "chucDanh_Id": chucDanh_Id,
        "nhiemVu": nhiemVu,
        "tenDonViKPI": tenDonViKPI,
        "tenPhongBan": tenPhongBan,
        "tenChucDanh": tenChucDanh,
        "tenChucVu": tenChucVu,
        "tyTrong": tyTrong,
        "diemTuDanhGia": diemTuDanhGia,
        "diemLanhDao": diemLanhDao,
        "nhomPIs": nhomPIs?.map((e) => e.toJson()).toList(),
        'kpiCaNhanNhomPIs': kpiCaNhanNhomPIs?.map((e) => e.toJson()).toList(),
      };
}

class NhomPIModel {
  String? vptq_kpi_NhomPI_Id;
  String? tenNhomPI;
  int? thuTuNhom;
  int? tongTyTrong;
  List<ChiTietPIModel>? chiTiets;
  bool? isTong; // Thuộc tính isTong

  double? _diemTrongSoTuDanhGia;
  double? get diemTrongSoTuDanhGia => _diemTrongSoTuDanhGia;

  // Setter
  set diemTrongSoTuDanhGia(double? value) {
    _diemTrongSoTuDanhGia = value;
  }

  NhomPIModel({this.vptq_kpi_NhomPI_Id, this.tenNhomPI, this.thuTuNhom, this.tongTyTrong, this.chiTiets, this.isTong = false});

  factory NhomPIModel.fromJson(Map<String, dynamic> json) {
    return NhomPIModel(
      vptq_kpi_NhomPI_Id: json["vptq_kpi_NhomPI_Id"],
      tenNhomPI: json["tenNhomPI"],
      thuTuNhom: json["thuTuNhom"],
      tongTyTrong: json["tongTyTrong"],
      isTong: json["isTong"] ?? false,
      chiTiets: (json["chiTiets"] as List?)?.map((e) => ChiTietPIModel.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        "vptq_kpi_NhomPI_Id": vptq_kpi_NhomPI_Id,
        "tenNhomPI": tenNhomPI,
        "thuTuNhom": thuTuNhom,
        "tongTyTrong": tongTyTrong,
        "chiTiets": chiTiets?.map((e) => e.toJson()).toList(),
      };
}

/// Helper parse an toàn
bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return null;
}

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.'));
  return null;
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

// ========== CHI TIẾT PI ==========
class ChiTietPIModel {
  // IDs & meta
  String? vptq_kpi_KPIDonViChiTietCon_Id;
  String? vptq_kpi_KPICaNhanChiTiet_Id;
  String? vptq_kpi_KPIDonViChiTiet_Id;
  String? vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id;
  String? vptq_kpi_DanhMucPIChiTietPhienBanCon_Id;
  String? vptq_kpi_DanhMucPIChiTietPhienBan_Id;
  String? vptq_kpi_KPICaNhan_Id;
  String? vptq_kpi_NhomPI_Id_Mobi;
  String? vptq_kpi_NhomPI_Id;
  String? vptq_kpi_DanhMucPIChiTiet_Id;
  String? vptq_kpi_KPICaNhanChiTietCon_Id;
  String? vptq_kpi_DanhMucPI_Id;

  // Nội dung PI
  String? maSoPI;
  String? tenNhomPI;
  String? maSoPICha_Mobi;
  String? chiSoDanhGia;
  String? chiSoDanhGiaChiTiet;
  String? tenDonViTinh;
  String? dienGiai;
  String? noiDungChiTieu; // có trong json
  String? noiDungChiTieuDanhGia; // có trong json
  String? dienGiaiDanhGia; // có trong json
  String? fileDinhKem; // có trong json (có thể null)

  // Thuộc tính đánh giá/điều kiện
  bool? isNoiDung;
  bool? isTang;
  bool? isKetQuaThucHien;
  bool? isKhongThucHien;
  bool? isCongDonGiaTriNam;
  bool? isCongDonPhanTramNam;
  bool? isThuocKPINam;
  bool? congDonNamPhanTram;
  int? chuKy; // 1/2...
  int? thuTu; // thứ tự trong nhóm
  int? tyTrong; // tỷ trọng (%)

  // Giá trị/điểm
  double? giaTriChiTieu;
  double? giaTriChiTieuDanhGia;

  // Kết quả tự đánh giá / lãnh đạo
  String? vptq_kpi_KetQuaTuDanhGia_Id;
  String? tenKetQuaTuDanhGia;
  int? diemKetQuaTuDanhGia, diemKetQuaTuDanhGiaFE;
  String? vptq_kpi_KetQuaTuDanhGiaCuTruocKhongThucHien_Id;
  String? tenKetQuaCuTruocKhongThucHien;
  int? diemKetQuaCuTruocKhongThucHien;

  String? vptq_kpi_KetQuaLanhDao_Id;
  String? tenKetQuaLanhDao;
  int? diemKetQuaLanhDao;

  // Tính điểm
  double? diemTrongSoTuDanhGia, diemTrongSoTuDanhGiaFE;
  double? diemTrongSoLanhDao;

  // Nguyên nhân/giải pháp
  bool? isNguyenNhanChuQuan;
  String? nguyenNhan;
  String? giaiPhap;

  // Cây con
  List<KetQuaModel>? ketQuas;
  List<ChiTietPIModel>? chiTietCons; // nếu có con
  bool? hasCon;

  double? phanTramKetQuaTuDanhGia, phanTramKetQuaTuDanhGiaFE;
  double? giaTriChiTieuDanhGiaFE;
  String? nguyenNhanFE, giaiPhapFE;

  bool? isDisableKhongThucHien;
  String? isNguyenNhanChuQuanFE;

  ChiTietPIModel(
      {this.vptq_kpi_KPICaNhanChiTiet_Id,
      this.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id,
      this.vptq_kpi_DanhMucPIChiTietPhienBan_Id,
      this.vptq_kpi_KPICaNhan_Id,
      this.vptq_kpi_NhomPI_Id_Mobi,
      this.vptq_kpi_DanhMucPIChiTiet_Id,
      this.vptq_kpi_KPIDonViChiTiet_Id,
      this.vptq_kpi_NhomPI_Id,
      this.vptq_kpi_DanhMucPI_Id,
      this.maSoPI,
      this.tenNhomPI,
      this.chiSoDanhGia,
      this.chiSoDanhGiaChiTiet,
      this.tenDonViTinh,
      this.dienGiai,
      this.noiDungChiTieu,
      this.noiDungChiTieuDanhGia,
      this.dienGiaiDanhGia,
      this.fileDinhKem,
      this.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id,
      this.isNoiDung,
      this.isTang,
      this.isKetQuaThucHien,
      this.isKhongThucHien,
      this.isCongDonGiaTriNam,
      this.isCongDonPhanTramNam,
      this.isThuocKPINam,
      this.congDonNamPhanTram,
      this.chuKy,
      this.thuTu,
      this.tyTrong,
      this.giaTriChiTieu,
      this.giaTriChiTieuDanhGia,
      this.vptq_kpi_KetQuaTuDanhGia_Id,
      this.tenKetQuaTuDanhGia,
      this.diemKetQuaTuDanhGia,
      this.vptq_kpi_KetQuaTuDanhGiaCuTruocKhongThucHien_Id,
      this.tenKetQuaCuTruocKhongThucHien,
      this.diemKetQuaCuTruocKhongThucHien,
      this.vptq_kpi_KetQuaLanhDao_Id,
      this.tenKetQuaLanhDao,
      this.diemKetQuaLanhDao,
      this.diemTrongSoTuDanhGia,
      this.diemTrongSoLanhDao,
      this.isNguyenNhanChuQuan,
      this.nguyenNhan,
      this.giaiPhap,
      this.ketQuas,
      this.chiTietCons,
      this.hasCon,
      this.diemTrongSoTuDanhGiaFE,
      this.phanTramKetQuaTuDanhGiaFE,
      this.phanTramKetQuaTuDanhGia,
      this.giaTriChiTieuDanhGiaFE,
      this.nguyenNhanFE,
      this.giaiPhapFE,
      this.isDisableKhongThucHien,
      this.diemKetQuaTuDanhGiaFE,
      this.vptq_kpi_KPICaNhanChiTietCon_Id,
      this.vptq_kpi_KPIDonViChiTietCon_Id,
      this.isNguyenNhanChuQuanFE,
      this.maSoPICha_Mobi});

  factory ChiTietPIModel.fromJson(Map<String, dynamic> json) => ChiTietPIModel(
        // IDs
        vptq_kpi_KPICaNhanChiTiet_Id: json["vptq_kpi_KPICaNhanChiTiet_Id"],
        vptq_kpi_KPIDonViChiTietCon_Id: json["vptq_kpi_KPIDonViChiTietCon_Id"],
        vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id: json["vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id"],
        vptq_kpi_DanhMucPIChiTietPhienBan_Id: json["vptq_kpi_DanhMucPIChiTietPhienBan_Id"],
        vptq_kpi_KPICaNhan_Id: json["vptq_kpi_KPICaNhan_Id"],
        vptq_kpi_NhomPI_Id_Mobi: json["vptq_kpi_NhomPI_Id_Mobi"],
        vptq_kpi_DanhMucPIChiTiet_Id: json["vptq_kpi_DanhMucPIChiTiet_Id"],
        vptq_kpi_KPIDonViChiTiet_Id: json["vptq_kpi_KPIDonViChiTiet_Id"],
        vptq_kpi_NhomPI_Id: json['vptq_kpi_NhomPI_Id'],
        vptq_kpi_DanhMucPI_Id: json['vptq_kpi_DanhMucPI_Id'],
        // Nội dung
        maSoPI: json["maSoPI"],
        tenNhomPI: json["tenNhomPI"],
        chiSoDanhGia: json["chiSoDanhGia"],
        chiSoDanhGiaChiTiet: json["chiSoDanhGiaChiTiet"],
        tenDonViTinh: json["tenDonViTinh"],
        dienGiai: json["dienGiai"],
        noiDungChiTieu: json["noiDungChiTieu"],
        noiDungChiTieuDanhGia: json["noiDungChiTieuDanhGia"],
        dienGiaiDanhGia: json["dienGiaiDanhGia"],
        fileDinhKem: json["fileDinhKem"],
        isDisableKhongThucHien: _parseBool(json["isDisableKhongThucHien"]),
        giaiPhapFE: json["giaiPhapFE"],
        nguyenNhanFE: json["nguyenNhanFE"],
        giaTriChiTieuDanhGiaFE: _parseDouble(json["giaTriChiTieuDanhGiaFE"]),
        phanTramKetQuaTuDanhGiaFE: _parseDouble(json["phanTramKetQuaTuDanhGiaFE"]),
        phanTramKetQuaTuDanhGia: _parseDouble(json["phanTramKetQuaTuDanhGia"]),
        diemTrongSoTuDanhGiaFE: _parseDouble(json["diemTrongSoTuDanhGiaFE"]),
        diemKetQuaTuDanhGiaFE: _parseInt(json["diemKetQuaTuDanhGiaFE"]),
        vptq_kpi_KPICaNhanChiTietCon_Id: json["vptq_kpi_KPICaNhanChiTietCon_Id"],
        maSoPICha_Mobi: json["maSoPICha_Mobi"],
        isNguyenNhanChuQuanFE: json["isNguyenNhanChuQuanFE"],
        vptq_kpi_DanhMucPIChiTietPhienBanCon_Id: json["vptq_kpi_DanhMucPIChiTietPhienBanCon_Id"],

        // flags & thứ tự
        isNoiDung: _parseBool(json["isNoiDung"]),
        isTang: _parseBool(json["isTang"]),
        isKetQuaThucHien: _parseBool(json["isKetQuaThucHien"]),
        isKhongThucHien: _parseBool(json["isKhongThucHien"]),
        isThuocKPINam: _parseBool(json['isThuocKPINam']),
        isCongDonGiaTriNam: _parseBool(json['isCongDonGiaTriNam']),
        isCongDonPhanTramNam: _parseBool(json['isCongDonPhanTramNam']),
        congDonNamPhanTram: _parseBool(json['congDonNamPhanTram']),
        chuKy: _parseInt(json["chuKy"]),
        thuTu: _parseInt(json["thuTu"]),
        tyTrong: _parseInt(json["tyTrong"]),

        // giá trị & điểm
        giaTriChiTieu: _parseDouble(json["giaTriChiTieu"]),
        giaTriChiTieuDanhGia: _parseDouble(json["giaTriChiTieuDanhGia"]),

        // kết quả tự đánh giá / lãnh đạo
        vptq_kpi_KetQuaTuDanhGia_Id: json["vptq_kpi_KetQuaTuDanhGia_Id"],
        tenKetQuaTuDanhGia: json["tenKetQuaTuDanhGia"],
        diemKetQuaTuDanhGia: _parseInt(json["diemKetQuaTuDanhGia"]),
        vptq_kpi_KetQuaTuDanhGiaCuTruocKhongThucHien_Id: json["vptq_kpi_KetQuaTuDanhGiaCuTruocKhongThucHien_Id"],
        tenKetQuaCuTruocKhongThucHien: json["tenKetQuaCuTruocKhongThucHien"],
        diemKetQuaCuTruocKhongThucHien: _parseInt(json["diemKetQuaCuTruocKhongThucHien"]),
        vptq_kpi_KetQuaLanhDao_Id: json["vptq_kpi_KetQuaLanhDao_Id"],
        tenKetQuaLanhDao: json["tenKetQuaLanhDao"],
        diemKetQuaLanhDao: _parseInt(json["diemKetQuaLanhDao"]),

        diemTrongSoTuDanhGia: _parseDouble(json["diemTrongSoTuDanhGia"]),
        diemTrongSoLanhDao: _parseDouble(json["diemTrongSoLanhDao"]),

        // nguyên nhân
        isNguyenNhanChuQuan: _parseBool(json["isNguyenNhanChuQuan"]),
        nguyenNhan: json["nguyenNhan"],
        giaiPhap: json["giaiPhap"],

        // con & list
        ketQuas: (json["ketQuas"] as List?)?.map((e) => KetQuaModel.fromJson(e as Map<String, dynamic>)).toList(),
        chiTietCons: (json["chiTietCons"] as List?)?.map((e) => ChiTietPIModel.fromJson(e as Map<String, dynamic>)).toList(),
        hasCon: _parseBool(json["hasCon"]),
      );

  Map<String, dynamic> toJson() => {
        "vptq_kpi_KPICaNhanChiTiet_Id": vptq_kpi_KPICaNhanChiTiet_Id,
        "vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id": vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id,
        "vptq_kpi_DanhMucPIChiTietPhienBan_Id": vptq_kpi_DanhMucPIChiTietPhienBan_Id,
        "vptq_kpi_KPICaNhan_Id": vptq_kpi_KPICaNhan_Id,
        "vptq_kpi_NhomPI_Id": vptq_kpi_NhomPI_Id_Mobi ?? vptq_kpi_NhomPI_Id,
        "vptq_kpi_DanhMucPIChiTiet_Id": vptq_kpi_DanhMucPIChiTiet_Id,
        "vptq_kpi_KPICaNhanChiTietCon_Id": vptq_kpi_KPICaNhanChiTietCon_Id,
        "vptq_kpi_DanhMucPI_Id": vptq_kpi_DanhMucPI_Id,
        "maSoPI": maSoPI,
        "tenNhomPI": tenNhomPI,
        "chiSoDanhGia": chiSoDanhGia,
        "chiSoDanhGiaChiTiet": chiSoDanhGiaChiTiet,
        "tenDonViTinh": tenDonViTinh,
        "dienGiai": dienGiai,
        "noiDungChiTieu": noiDungChiTieu,
        "noiDungChiTieuDanhGia": noiDungChiTieuDanhGia,
        "dienGiaiDanhGia": dienGiaiDanhGia,
        "fileDinhKem": fileDinhKem,
        "isNoiDung": isNoiDung,
        "isTang": isTang,
        "isKetQuaThucHien": isKetQuaThucHien,
        "isKhongThucHien": isKhongThucHien,
        "chuKy": chuKy,
        "thuTu": thuTu,
        "tyTrong": tyTrong,
        "giaTriChiTieu": giaTriChiTieu,
        "giaTriChiTieuDanhGia": giaTriChiTieuDanhGia,
        "vptq_kpi_KetQuaTuDanhGia_Id": vptq_kpi_KetQuaTuDanhGia_Id,
        "tenKetQuaTuDanhGia": tenKetQuaTuDanhGia,
        "diemKetQuaTuDanhGia": diemKetQuaTuDanhGia,
        "vptq_kpi_KetQuaTuDanhGiaCuTruocKhongThucHien_Id": vptq_kpi_KetQuaTuDanhGiaCuTruocKhongThucHien_Id,
        "tenKetQuaCuTruocKhongThucHien": tenKetQuaCuTruocKhongThucHien,
        "diemKetQuaCuTruocKhongThucHien": diemKetQuaCuTruocKhongThucHien,
        "vptq_kpi_KetQuaLanhDao_Id": vptq_kpi_KetQuaLanhDao_Id,
        "tenKetQuaLanhDao": tenKetQuaLanhDao,
        "diemKetQuaLanhDao": diemKetQuaLanhDao,
        "diemTrongSoTuDanhGia": diemTrongSoTuDanhGia,
        "diemTrongSoLanhDao": diemTrongSoLanhDao,
        "isNguyenNhanChuQuan": isNguyenNhanChuQuan,
        "nguyenNhan": nguyenNhan,
        "giaiPhap": giaiPhap,
        "chiTietCons": chiTietCons?.map((e) => e.toJson()).toList(),
        "hasCon": hasCon,
      };
}

class KetQuaModel {
  double? nhoHon;
  double? lonHonHoacBang;
  String? noiDung;
  String? vptq_kpi_KetQuaDanhGia_Id;
  String? tenKetQuaDanhGia;
  String? tenDonViTinh;
  int? diem;

  KetQuaModel({
    this.nhoHon,
    this.lonHonHoacBang,
    this.noiDung,
    this.vptq_kpi_KetQuaDanhGia_Id,
    this.tenKetQuaDanhGia,
    this.diem,
    this.tenDonViTinh,
  });

  factory KetQuaModel.fromJson(Map<String, dynamic> json) {
    return KetQuaModel(
      nhoHon: (json["nhoHon"] as num?)?.toDouble(),
      lonHonHoacBang: (json["lonHonHoacBang"] as num?)?.toDouble(),
      noiDung: json["noiDung"],
      vptq_kpi_KetQuaDanhGia_Id: json["vptq_kpi_KetQuaDanhGia_Id"],
      tenKetQuaDanhGia: json["tenKetQuaDanhGia"],
      tenDonViTinh: json["tenDonViTinh"],
      diem: json["diem"],
    );
  }
}

class ThangDiemXepLoaiChiTietModel {
  String? vptq_kpi_ThangDiemXepLoaiChiTiet_Id;
  double? nhoHon;
  double? lonHonBang;
  String? mucDiem;
  String? vptq_kpi_ThangDiemXepLoai_Id;
  String? xepLoai;

  ThangDiemXepLoaiChiTietModel({
    this.vptq_kpi_ThangDiemXepLoaiChiTiet_Id,
    this.nhoHon,
    this.lonHonBang,
    this.mucDiem,
    this.vptq_kpi_ThangDiemXepLoai_Id,
    this.xepLoai,
  });

  factory ThangDiemXepLoaiChiTietModel.fromJson(Map<String, dynamic> json) {
    return ThangDiemXepLoaiChiTietModel(
      vptq_kpi_ThangDiemXepLoaiChiTiet_Id: json["vptq_kpi_ThangDiemXepLoaiChiTiet_Id"],
      nhoHon: (json["nhoHon"] as num?)?.toDouble(),
      lonHonBang: (json["lonHonBang"] as num?)?.toDouble(),
      mucDiem: json["mucDiem"],
      vptq_kpi_ThangDiemXepLoai_Id: json["vptq_kpi_ThangDiemXepLoai_Id"],
      xepLoai: json["xepLoai"],
    );
  }
  Map<String, dynamic> toJson() => {
        "vptq_kpi_ThangDiemXepLoaiChiTiet_Id": vptq_kpi_ThangDiemXepLoaiChiTiet_Id,
        "nhoHon": nhoHon,
        "lonHonBang": lonHonBang,
        "mucDiem": mucDiem,
        "vptq_kpi_ThangDiemXepLoai_Id": vptq_kpi_ThangDiemXepLoai_Id,
        "xepLoai": xepLoai,
      };
}
