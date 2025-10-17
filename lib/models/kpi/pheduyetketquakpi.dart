// Root
class PheDuyetKetQuaKPIModel {
  String? id;
  bool? isLanhDaoTiemNang;
  int? viTriDuyet;
  bool? isHoanThanh;
  bool? isDuyet0, isDuyet1, isDuyet2, isDuyet3;

  String? ngayTao;
  String? thoiGianDuyet0, thoiGianDuyet1, thoiGianDuyet2, thoiGianDuyet3;

  String? nguoiTao_Id, tenNguoiTao;
  String? kiemTra1_Id, tenKiemTra1, maKiemTra1;
  String? kiemTra2_Id, tenKiemTra2, maKiemTra2;
  String? kiemTra_Id, tenKiemTra;

  String? pheDuyet_Id, tenPheDuyet, maPheDuyet;
  String? nguoiDuyetHienTai_Id, tenNguoiDuyetHienTai, maNguoiDuyetHienTai;

  String? vptq_kpi_DonViKPI_Id, maDonViKPI, tenDonViKPI;
  String? vptq_kpi_KyDanhGiaKPI_Id;

  String? thoiDiem;
  int? chuKy, thang, nam, kyQuy;

  String? vptq_kpi_ThangDiemXepLoai_Id, tenThangDiemXepLoai, maThangDiemXepLoai;

  int? trangThai;

  List<ChiTietModel>? chiTiets;
  List<XepLoaiChiTietModel>? thangDiemXepLoaiChiTiets;
  List<XepLoaiChiTietModel>? tyLeXepLoais;

  PheDuyetKetQuaKPIModel({
    this.id,
    this.isLanhDaoTiemNang,
    this.viTriDuyet,
    this.isHoanThanh,
    this.isDuyet0,
    this.isDuyet1,
    this.isDuyet2,
    this.isDuyet3,
    this.ngayTao,
    this.tenKiemTra,
    this.thoiGianDuyet0,
    this.thoiGianDuyet1,
    this.thoiGianDuyet2,
    this.thoiGianDuyet3,
    this.nguoiTao_Id,
    this.tenNguoiTao,
    this.kiemTra1_Id,
    this.tenKiemTra1,
    this.maKiemTra1,
    this.kiemTra2_Id,
    this.tenKiemTra2,
    this.maKiemTra2,
    this.pheDuyet_Id,
    this.tenPheDuyet,
    this.maPheDuyet,
    this.nguoiDuyetHienTai_Id,
    this.tenNguoiDuyetHienTai,
    this.maNguoiDuyetHienTai,
    this.vptq_kpi_DonViKPI_Id,
    this.maDonViKPI,
    this.tenDonViKPI,
    this.vptq_kpi_KyDanhGiaKPI_Id,
    this.thoiDiem,
    this.chuKy,
    this.thang,
    this.nam,
    this.kyQuy,
    this.vptq_kpi_ThangDiemXepLoai_Id,
    this.tenThangDiemXepLoai,
    this.maThangDiemXepLoai,
    this.trangThai,
    this.chiTiets,
    this.thangDiemXepLoaiChiTiets,
    this.tyLeXepLoais,
  });

  factory PheDuyetKetQuaKPIModel.fromJson(Map<String, dynamic> j) {
    List<XepLoaiChiTietModel>? _mapXL(dynamic v) => (v as List?)?.map((e) => XepLoaiChiTietModel.fromJson(e)).toList();

    return PheDuyetKetQuaKPIModel(
      id: j['id']?.toString(),
      isLanhDaoTiemNang: j['isLanhDaoTiemNang'] as bool?,
      viTriDuyet: j['viTriDuyet'] as int?,
      isHoanThanh: j['isHoanThanh'] as bool?,
      isDuyet0: j['isDuyet0'] as bool?,
      isDuyet1: j['isDuyet1'] as bool?,
      isDuyet2: j['isDuyet2'] as bool?,
      isDuyet3: j['isDuyet3'] as bool?,
      ngayTao: j['ngayTao'] as String?,
      thoiGianDuyet0: j['thoiGianDuyet0'] as String?,
      thoiGianDuyet1: j['thoiGianDuyet1'] as String?,
      thoiGianDuyet2: j['thoiGianDuyet2'] as String?,
      thoiGianDuyet3: j['thoiGianDuyet3'] as String?,
      nguoiTao_Id: j['nguoiTao_Id'] as String?,
      tenNguoiTao: j['tenNguoiTao'] as String?,
      kiemTra1_Id: j['kiemTra1_Id'] as String?,
      tenKiemTra1: j['tenKiemTra1'] as String?,
      maKiemTra1: j['maKiemTra1'] as String?,
      tenKiemTra: j['tenKiemTra'] as String?,
      kiemTra2_Id: j['kiemTra2_Id'] as String?,
      tenKiemTra2: j['tenKiemTra2'] as String?,
      maKiemTra2: j['maKiemTra2'] as String?,
      pheDuyet_Id: j['pheDuyet_Id'] as String?,
      tenPheDuyet: j['tenPheDuyet'] as String?,
      maPheDuyet: j['maPheDuyet'] as String?,
      nguoiDuyetHienTai_Id: j['nguoiDuyetHienTai_Id'] as String?,
      tenNguoiDuyetHienTai: j['tenNguoiDuyetHienTai'] as String?,
      maNguoiDuyetHienTai: j['maNguoiDuyetHienTai'] as String?,
      vptq_kpi_DonViKPI_Id: j['vptq_kpi_DonViKPI_Id'] as String?,
      maDonViKPI: j['maDonViKPI'] as String?,
      tenDonViKPI: j['tenDonViKPI'] as String?,
      vptq_kpi_KyDanhGiaKPI_Id: j['vptq_kpi_KyDanhGiaKPI_Id'] as String?,
      thoiDiem: j['thoiDiem'] as String?,
      chuKy: j['chuKy'] as int?,
      thang: j['thang'] as int?,
      nam: j['nam'] as int?,
      kyQuy: j['kyQuy'] as int?,
      vptq_kpi_ThangDiemXepLoai_Id: j['vptq_kpi_ThangDiemXepLoai_Id'] as String?,
      tenThangDiemXepLoai: j['tenThangDiemXepLoai'] as String?,
      maThangDiemXepLoai: j['maThangDiemXepLoai'] as String?,
      trangThai: j['trangThai'] as int?,
      chiTiets: (j['chiTiets'] as List?)?.map((e) => ChiTietModel.fromJson(e)).toList(),
      thangDiemXepLoaiChiTiets: _mapXL(j['thangDiemXepLoaiChiTiets']),
      tyLeXepLoais: _mapXL(j['tyLeXepLoais']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isLanhDaoTiemNang': isLanhDaoTiemNang,
        'viTriDuyet': viTriDuyet,
        'isHoanThanh': isHoanThanh,
        'isDuyet0': isDuyet0,
        'isDuyet1': isDuyet1,
        'isDuyet2': isDuyet2,
        'isDuyet3': isDuyet3,
        'ngayTao': ngayTao,
        'thoiGianDuyet0': thoiGianDuyet0,
        'thoiGianDuyet1': thoiGianDuyet1,
        'thoiGianDuyet2': thoiGianDuyet2,
        'thoiGianDuyet3': thoiGianDuyet3,
        'nguoiTao_Id': nguoiTao_Id,
        'tenNguoiTao': tenNguoiTao,
        'kiemTra1_Id': kiemTra1_Id,
        'tenKiemTra1': tenKiemTra1,
        'maKiemTra1': maKiemTra1,
        'kiemTra2_Id': kiemTra2_Id,
        'tenKiemTra2': tenKiemTra2,
        'maKiemTra2': maKiemTra2,
        'pheDuyet_Id': pheDuyet_Id,
        'tenPheDuyet': tenPheDuyet,
        'maPheDuyet': maPheDuyet,
        'nguoiDuyetHienTai_Id': nguoiDuyetHienTai_Id,
        'tenNguoiDuyetHienTai': tenNguoiDuyetHienTai,
        'maNguoiDuyetHienTai': maNguoiDuyetHienTai,
        'vptq_kpi_DonViKPI_Id': vptq_kpi_DonViKPI_Id,
        'maDonViKPI': maDonViKPI,
        'tenDonViKPI': tenDonViKPI,
        'vptq_kpi_KyDanhGiaKPI_Id': vptq_kpi_KyDanhGiaKPI_Id,
        'thoiDiem': thoiDiem,
        'chuKy': chuKy,
        'thang': thang,
        'nam': nam,
        'kyQuy': kyQuy,
        'vptq_kpi_ThangDiemXepLoai_Id': vptq_kpi_ThangDiemXepLoai_Id,
        'tenThangDiemXepLoai': tenThangDiemXepLoai,
        'maThangDiemXepLoai': maThangDiemXepLoai,
        'trangThai': trangThai,
        'chiTiets': chiTiets?.map((e) => e.toJson()).toList(),
        'thangDiemXepLoaiChiTiets': thangDiemXepLoaiChiTiets?.map((e) => e.toJson()).toList(),
        'tyLeXepLoais': tyLeXepLoais?.map((e) => e.toJson()).toList(),
      };
}

// Chi tiết nhân sự
class ChiTietModel {
  String? vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhanChiTiet_Id;

  String? user_Id, tenUser, maUser;

  bool? isKhongDanhGia, isHoanThanh, isKhongThucHien;

  String? vptq_kpi_ThangDiemXepLoaiChiTiet_Id;
  String? xepLoai, moTa;

  double? diemKetQua, diemCong, diemTru, diemKetQuaCuoiCung;

  String? chucDanh_Id, tenChucDanh;
  String? chucVu_Id, tenChucVu;

  String? phongBanThaco_Id, maPhongBan, tenPhongBan;

  String? vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan_Id;

  String? vptq_kpi_DonViKPI_Id, maDonViKPI, tenDonViKPI;

  String? vptq_kpi_KPICaNhan_Id;

  String? vptq_kpi_NhanSuKhongDanhGia_Id;
  String? vptq_kpi_LyDoKhongDanhGia_Id;
  String? lyDoKhongDanhGia;
  String? tenLanhDaoDonVi;

  double? diemCongBanDau, diemKetQuaBanDau, diemKetQuaCuoiCungBanDau, diemTruBanDau;
  int? soLuongBeHonBang2, soLuongBeHonBang1, lonNhuanKhongDuong, soSuCo;

  ChiTietModel({
    this.vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhanChiTiet_Id,
    this.user_Id,
    this.tenUser,
    this.maUser,
    this.isKhongDanhGia,
    this.isHoanThanh,
    this.isKhongThucHien,
    this.vptq_kpi_ThangDiemXepLoaiChiTiet_Id,
    this.xepLoai,
    this.moTa,
    this.diemKetQua,
    this.diemCong,
    this.diemTru,
    this.diemKetQuaCuoiCung,
    this.chucDanh_Id,
    this.tenChucDanh,
    this.chucVu_Id,
    this.tenChucVu,
    this.phongBanThaco_Id,
    this.maPhongBan,
    this.tenPhongBan,
    this.vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan_Id,
    this.vptq_kpi_DonViKPI_Id,
    this.maDonViKPI,
    this.tenDonViKPI,
    this.vptq_kpi_KPICaNhan_Id,
    this.vptq_kpi_NhanSuKhongDanhGia_Id,
    this.vptq_kpi_LyDoKhongDanhGia_Id,
    this.lyDoKhongDanhGia,
    this.diemCongBanDau,
    this.diemKetQuaBanDau,
    this.diemKetQuaCuoiCungBanDau,
    this.diemTruBanDau,
    this.lonNhuanKhongDuong,
    this.soLuongBeHonBang1,
    this.soLuongBeHonBang2,
    this.soSuCo,
    this.tenLanhDaoDonVi,
  });

  factory ChiTietModel.fromJson(Map<String, dynamic> j) => ChiTietModel(
        vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhanChiTiet_Id: j['vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhanChiTiet_Id'] as String?,
        user_Id: j['user_Id'] as String?,
        tenLanhDaoDonVi: j['tenLanhDaoDonVi'] as String?,
        soLuongBeHonBang1: (j['soLuongBeHonBang1'] as num?)?.toInt(),
        soLuongBeHonBang2: (j['soLuongBeHonBang2'] as num?)?.toInt(),
        lonNhuanKhongDuong: (j['lonNhuanKhongDuong'] as num?)?.toInt(),
        soSuCo: (j['soSuCo'] as num?)?.toInt(),
        tenUser: j['tenUser'] as String?,
        maUser: j['maUser'] as String?,
        isKhongDanhGia: j['isKhongDanhGia'] as bool?,
        isHoanThanh: j['isHoanThanh'] as bool?,
        isKhongThucHien: j['isKhongThucHien'] as bool?,
        vptq_kpi_ThangDiemXepLoaiChiTiet_Id: j['vptq_kpi_ThangDiemXepLoaiChiTiet_Id'] as String?,
        xepLoai: j['xepLoai'] as String?,
        moTa: j['moTa'] as String?,
        diemKetQua: (j['diemKetQua'] as num?)?.toDouble(),
        diemCong: (j['diemCong'] as num?)?.toDouble(),
        diemTru: (j['diemTru'] as num?)?.toDouble(),
        diemKetQuaCuoiCung: (j['diemKetQuaCuoiCung'] as num?)?.toDouble(),
        chucDanh_Id: j['chucDanh_Id'] as String?,
        tenChucDanh: j['tenChucDanh'] as String?,
        chucVu_Id: j['chucVu_Id'] as String?,
        tenChucVu: j['tenChucVu'] as String?,
        phongBanThaco_Id: j['phongBanThaco_Id'] as String?,
        maPhongBan: j['maPhongBan'] as String?,
        tenPhongBan: j['tenPhongBan'] as String?,
        vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan_Id: j['vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan_Id'] as String?,
        vptq_kpi_DonViKPI_Id: j['vptq_kpi_DonViKPI_Id'] as String?,
        maDonViKPI: j['maDonViKPI'] as String?,
        tenDonViKPI: j['tenDonViKPI'] as String?,
        vptq_kpi_KPICaNhan_Id: j['vptq_kpi_KPICaNhan_Id'] as String?,
        vptq_kpi_NhanSuKhongDanhGia_Id: j['vptq_kpi_NhanSuKhongDanhGia_Id'] as String?,
        vptq_kpi_LyDoKhongDanhGia_Id: j['vptq_kpi_LyDoKhongDanhGia_Id'] as String?,
        lyDoKhongDanhGia: j['lyDoKhongDanhGia'] as String?,
        diemCongBanDau: (j['diemCongBanDau'] as num?)?.toDouble(),
        diemKetQuaBanDau: (j['diemKetQuaBanDau'] as num?)?.toDouble(),
        diemKetQuaCuoiCungBanDau: (j['diemKetQuaCuoiCungBanDau'] as num?)?.toDouble(),
        diemTruBanDau: (j['diemTruBanDau'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhanChiTiet_Id': vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhanChiTiet_Id,
        'user_Id': user_Id,
        'tenUser': tenUser,
        'maUser': maUser,
        'isKhongDanhGia': isKhongDanhGia,
        'isHoanThanh': isHoanThanh,
        'isKhongThucHien': isKhongThucHien,
        'vptq_kpi_ThangDiemXepLoaiChiTiet_Id': vptq_kpi_ThangDiemXepLoaiChiTiet_Id,
        'xepLoai': xepLoai,
        'moTa': moTa,
        'diemKetQua': diemKetQua,
        'diemCong': diemCong,
        'diemTru': diemTru,
        'diemKetQuaCuoiCung': diemKetQuaCuoiCung,
        'chucDanh_Id': chucDanh_Id,
        'tenChucDanh': tenChucDanh,
        'chucVu_Id': chucVu_Id,
        'tenChucVu': tenChucVu,
        'phongBanThaco_Id': phongBanThaco_Id,
        'maPhongBan': maPhongBan,
        'tenPhongBan': tenPhongBan,
        'vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan_Id': vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan_Id,
        'vptq_kpi_DonViKPI_Id': vptq_kpi_DonViKPI_Id,
        'maDonViKPI': maDonViKPI,
        'tenDonViKPI': tenDonViKPI,
        'vptq_kpi_KPICaNhan_Id': vptq_kpi_KPICaNhan_Id,
        'vptq_kpi_NhanSuKhongDanhGia_Id': vptq_kpi_NhanSuKhongDanhGia_Id,
        'vptq_kpi_LyDoKhongDanhGia_Id': vptq_kpi_LyDoKhongDanhGia_Id,
        'lyDoKhongDanhGia': lyDoKhongDanhGia,
        'diemCongBanDau': diemCongBanDau,
        'diemKetQuaBanDau': diemKetQuaBanDau,
        'diemKetQuaCuoiCungBanDau': diemKetQuaCuoiCungBanDau,
        'diemTruBanDau': diemTruBanDau,
      };
}

// Dùng chung cho "thangDiemXepLoaiChiTiets" và "tyLeXepLoais"
class XepLoaiChiTietModel {
  String? vptq_kpi_ThangDiemXepLoaiChiTiet_Id;
  String? xepLoai;
  String? mucDiem;
  double? lonHonBang;
  double? nhoHon;
  int? soLuong;
  double? tyLe;

  XepLoaiChiTietModel({
    this.vptq_kpi_ThangDiemXepLoaiChiTiet_Id,
    this.xepLoai,
    this.mucDiem,
    this.lonHonBang,
    this.nhoHon,
    this.soLuong,
    this.tyLe,
  });

  factory XepLoaiChiTietModel.fromJson(Map<String, dynamic> j) => XepLoaiChiTietModel(
        vptq_kpi_ThangDiemXepLoaiChiTiet_Id: j['vptq_kpi_ThangDiemXepLoaiChiTiet_Id'] as String?,
        xepLoai: j['xepLoai'] as String?,
        mucDiem: j['mucDiem'] as String?,
        lonHonBang: (j['lonHonBang'] as num?)?.toDouble(),
        nhoHon: (j['nhoHon'] as num?)?.toDouble(),
        soLuong: j['soLuong'] as int?,
        tyLe: (j['tyLe'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_ThangDiemXepLoaiChiTiet_Id': vptq_kpi_ThangDiemXepLoaiChiTiet_Id,
        'xepLoai': xepLoai,
        'mucDiem': mucDiem,
        'lonHonBang': lonHonBang,
        'nhoHon': nhoHon,
        'soLuong': soLuong,
        'tyLe': tyLe,
      };
}
