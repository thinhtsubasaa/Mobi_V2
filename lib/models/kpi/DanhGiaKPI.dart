/// ---------- Root response ----------
class KpiListResponse {
  final int? totalRow;
  final int? totalPage;
  final int? pageSize;
  final KpiDataList? datalist;

  const KpiListResponse({
    this.totalRow,
    this.totalPage,
    this.pageSize,
    this.datalist,
  });

  factory KpiListResponse.fromJson(Map<String, dynamic> json) => KpiListResponse(
        totalRow: (json['totalRow'] as num?)?.toInt(),
        totalPage: (json['totalPage'] as num?)?.toInt(),
        pageSize: (json['pageSize'] as num?)?.toInt(),
        datalist: json['datalist'] == null ? null : KpiDataList.fromJson(json['datalist'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'totalRow': totalRow,
        'totalPage': totalPage,
        'pageSize': pageSize,
        'datalist': datalist?.toJson(),
      };
}

/// ---------- datalist ----------
class KpiDataList {
  final int? soLuong;
  final int? soLuongHoanThanh;
  final int? soLuongChuaDanhGia;
  final int? soLuongTraLai;
  final int? soLuongChoBanDuyet;
  final int? soLuongDangXuLy;
  final List<TyTrongXepLoai> tyTrongXepLoais;
  final List<DanhGiaKPIModel> data;

  const KpiDataList({
    this.soLuong,
    this.soLuongHoanThanh,
    this.soLuongChuaDanhGia,
    this.soLuongTraLai,
    this.soLuongChoBanDuyet,
    this.soLuongDangXuLy,
    this.tyTrongXepLoais = const [],
    this.data = const [],
  });

  factory KpiDataList.fromJson(Map<String, dynamic> json) => KpiDataList(
        soLuong: (json['soLuong'] as num?)?.toInt(),
        soLuongHoanThanh: (json['soLuongHoanThanh'] as num?)?.toInt(),
        soLuongChuaDanhGia: (json['soLuongChuaDanhGia'] as num?)?.toInt(),
        soLuongTraLai: (json['soLuongTraLai'] as num?)?.toInt(),
        soLuongChoBanDuyet: (json['soLuongChoBanDuyet'] as num?)?.toInt(),
        soLuongDangXuLy: (json['soLuongDangXuLy'] as num?)?.toInt(),
        tyTrongXepLoais: (json['tyTrongXepLoais'] as List? ?? []).map((e) => TyTrongXepLoai.fromJson(e as Map<String, dynamic>)).toList(),
        data: (json['data'] as List? ?? []).map((e) => DanhGiaKPIModel.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'soLuong': soLuong,
        'soLuongHoanThanh': soLuongHoanThanh,
        'soLuongChuaDanhGia': soLuongChuaDanhGia,
        'soLuongTraLai': soLuongTraLai,
        'soLuongChoBanDuyet': soLuongChoBanDuyet,
        'soLuongDangXuLy': soLuongDangXuLy,
        'tyTrongXepLoais': tyTrongXepLoais.map((e) => e.toJson()).toList(),
        'data': data.map((e) => e.toJson()).toList(),
      };
}

/// ---------- tỷ trọng xếp loại ----------
class TyTrongXepLoai {
  final String? chiTietId; // vptq_kpi_ThangDiemXepLoaiChiTiet_Id
  final String? xepLoai;
  final int? soLuong;
  final String? mucDiem;
  final num? phanTram;

  const TyTrongXepLoai({
    this.chiTietId,
    this.xepLoai,
    this.soLuong,
    this.mucDiem,
    this.phanTram,
  });

  factory TyTrongXepLoai.fromJson(Map<String, dynamic> json) => TyTrongXepLoai(
        chiTietId: json['vptq_kpi_ThangDiemXepLoaiChiTiet_Id']?.toString(),
        xepLoai: json['xepLoai'],
        soLuong: (json['soLuong'] as num?)?.toInt(),
        mucDiem: json['mucDiem'],
        phanTram: json['phanTram'] as num?,
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_ThangDiemXepLoaiChiTiet_Id': chiTietId,
        'xepLoai': xepLoai,
        'soLuong': soLuong,
        'mucDiem': mucDiem,
        'phanTram': phanTram,
      };
}

/// ---------- từng bản ghi trong `data` ----------
class DanhGiaKPIModel {
  final String? id;
  final bool? isDongDanhGia;
  final bool? isDong;
  final bool? isLanhDaoTiemNang;
  final bool? isLanhDaoDonVi;
  final bool? isHoanThanhDanhGia;
  final bool? isTraLaiDanhGia;
  final String? nhiemVu;
  final int? viTriDuyetDanhGia;
  final bool? isCoQuyenChuyenVienKPI;
  final bool? isThucHienChinhSuaCVKPI;
  final bool? isHoanThanh;
  final int? viTriDuyet;

  final String? ngayTao; // giữ String "dd/MM/yyyy HH:mm:ss"
  final String? thoiGianHoanThanh;

  final String? user_Id;
  final String? nguoiTaoId;
  final String? nguoiDuyetDanhGia1Id;
  final String? nguoiDuyetDanhGia2Id;
  final String? nguoiDuyetDanhGia3Id;
  final String? nguoiDuyetDanhGia4Id;
  final String? nguoiDuyetDanhGia5Id;
  final String? nguoiDuyetDanhGiaHienTaiId;

  final String? tenUser;
  final String? maUser;
  final String? tenNguoiTao;
  final String? maNguoiTao;
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
  final String? tenNguoiDuyetHienTai;
  final String? maNguoiDuyetHienTai;

  final String? chucDanhId;
  final String? chucVuId;
  final String? phongBanThacoId;

  final String? vptqKpiDonViKpiId; // vptq_kpi_DonViKPI_Id
  final String? vptqKpiKyDanhGiaKpiId;

  final String? tenChucDanh;
  final String? maChucDanh;
  final String? tenChucVu;
  final String? tenPhongBan;

  final String? maDonViKPI;
  final String? tenDonViKPI;

  final int? thang;
  final int? nam;
  final int? chuKy;
  final int? kyQuy;
  final String? thoiDiem; // "MM/yyyy"

  final num? diemCong;
  final num? diemKetQua;
  final num? diemKetQuaTamThoi;
  final num? diemKetQuaTuDanhGia;
  final num? diemKetQuaCuoiCung;
  final num? diemTru;

  final String? nhanXetDanhGia1;
  final String? nhanXetDanhGia2;
  final String? nhanXetDanhGia3;
  final String? nhanXetDanhGia4;
  final String? nhanXetDanhGia5;

  final bool? isThucHienDanhGia;
  final String? capDoNhanSu;
  final int? trangThai;
  final bool? isThucHienDuyetKpiCvDv;
  final bool? isUyQuyen;
  final bool? isThucHienTuDanhGia;

  final String? lyDoKhongDanhGiaId;
  final String? maLyDoKhongDanhGia;
  final String? lyDoKhongDanhGia;
  final bool? isKhongDanhGia;
  final bool? isCvkpiTong;

  final String? capDoNhanSuId;
  final String? thangDiemXepLoaiChiTietId;
  final String? tenCapDoNhanSu;
  final String? xepLoai;
  final bool? isDaXem;

  const DanhGiaKPIModel({
    this.id,
    this.isDongDanhGia,
    this.isLanhDaoTiemNang,
    this.isLanhDaoDonVi,
    this.isHoanThanhDanhGia,
    this.isTraLaiDanhGia,
    this.nhiemVu,
    this.isDong,
    this.viTriDuyetDanhGia,
    this.ngayTao,
    this.thoiGianHoanThanh,
    this.user_Id,
    this.nguoiTaoId,
    this.nguoiDuyetDanhGia1Id,
    this.nguoiDuyetDanhGia2Id,
    this.nguoiDuyetDanhGia3Id,
    this.nguoiDuyetDanhGia4Id,
    this.nguoiDuyetDanhGia5Id,
    this.nguoiDuyetDanhGiaHienTaiId,
    this.tenUser,
    this.maUser,
    this.tenNguoiTao,
    this.maNguoiTao,
    this.chucDanhId,
    this.isCoQuyenChuyenVienKPI,
    this.isThucHienChinhSuaCVKPI,
    this.isHoanThanh,
    this.viTriDuyet,
    this.chucVuId,
    this.phongBanThacoId,
    this.vptqKpiDonViKpiId,
    this.vptqKpiKyDanhGiaKpiId,
    this.tenChucDanh,
    this.maChucDanh,
    this.tenChucVu,
    this.tenPhongBan,
    this.maDonViKPI,
    this.tenDonViKPI,
    this.thang,
    this.nam,
    this.chuKy,
    this.kyQuy,
    this.thoiDiem,
    this.diemCong,
    this.diemKetQua,
    this.diemKetQuaTamThoi,
    this.diemKetQuaTuDanhGia,
    this.diemKetQuaCuoiCung,
    this.diemTru,
    this.nhanXetDanhGia1,
    this.nhanXetDanhGia2,
    this.nhanXetDanhGia3,
    this.nhanXetDanhGia4,
    this.nhanXetDanhGia5,
    this.isThucHienDanhGia,
    this.capDoNhanSu,
    this.trangThai,
    this.isThucHienDuyetKpiCvDv,
    this.isUyQuyen,
    this.isThucHienTuDanhGia,
    this.lyDoKhongDanhGiaId,
    this.maLyDoKhongDanhGia,
    this.lyDoKhongDanhGia,
    this.isKhongDanhGia,
    this.isCvkpiTong,
    this.capDoNhanSuId,
    this.thangDiemXepLoaiChiTietId,
    this.tenCapDoNhanSu,
    this.xepLoai,
    this.isDaXem,
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
    this.maNguoiDuyetHienTai,
    this.tenNguoiDuyetHienTai,
  });

  factory DanhGiaKPIModel.fromJson(Map<String, dynamic> json) => DanhGiaKPIModel(
        id: json['id']?.toString(),
        isDongDanhGia: _toBool(json['isDongDanhGia']),
        isDong: _toBool(json['isDong']),
        isLanhDaoTiemNang: _toBool(json['isLanhDaoTiemNang']),
        isLanhDaoDonVi: _toBool(json['isLanhDaoDonVi']),
        isHoanThanhDanhGia: _toBool(json['isHoanThanhDanhGia']),
        isTraLaiDanhGia: _toBool(json['isTraLaiDanhGia']),
        nhiemVu: json['nhiemVu'],
        viTriDuyetDanhGia: (json['viTriDuyetDanhGia'] as num?)?.toInt(),
        ngayTao: json['ngayTao'],
        thoiGianHoanThanh: json['thoiGianHoanThanh']?.toString(),
        user_Id: json['user_Id']?.toString(),
        nguoiTaoId: json['nguoiTao_Id']?.toString(),
        nguoiDuyetDanhGia1Id: (json['nguoiDuyetDanhGia1_Id'] ?? json['nguoiDuyet1_Id'])?.toString(),
        nguoiDuyetDanhGia2Id: (json['nguoiDuyetDanhGia2_Id'] ?? json['nguoiDuyet2_Id'])?.toString(),
        nguoiDuyetDanhGia3Id: (json['nguoiDuyetDanhGia3_Id'] ?? json['nguoiDuyet3_Id'])?.toString(),
        nguoiDuyetDanhGia4Id: (json['nguoiDuyetDanhGia4_Id'] ?? json['nguoiDuyet4_Id'])?.toString(),
        nguoiDuyetDanhGia5Id: (json['nguoiDuyetDanhGia5_Id'] ?? json['nguoiDuyet5_Id'])?.toString(),
        nguoiDuyetDanhGiaHienTaiId: (json['nguoiDuyetDanhGiaHienTai_Id'] ?? json['nguoiDuyetHienTai_Id'])?.toString(),
        isCoQuyenChuyenVienKPI: _toBool(json['isCoQuyenChuyenVienKPI']),
        isThucHienChinhSuaCVKPI: _toBool(json['isThucHienChinhSuaCVKPI']),
        isHoanThanh: _toBool(json['isHoanThanh']),
        tenUser: json['tenUser'],
        viTriDuyet: (json['viTriDuyet'] as num?)?.toInt(),
        maUser: json['maUser'],
        tenNguoiTao: json['tenNguoiTao'],
        maNguoiTao: json['maNguoiTao'],
        chucDanhId: json['chucDanh_Id']?.toString(),
        chucVuId: json['chucVu_Id']?.toString(),
        phongBanThacoId: json['phongBanThaco_Id']?.toString(),
        vptqKpiDonViKpiId: json['vptq_kpi_DonViKPI_Id']?.toString(),
        vptqKpiKyDanhGiaKpiId: json['vptq_kpi_KyDanhGiaKPI_Id']?.toString(),
        tenChucDanh: json['tenChucDanh'],
        maChucDanh: json['maChucDanh'],
        tenChucVu: json['tenChucVu'],
        tenPhongBan: json['tenPhongBan'],
        maDonViKPI: json['maDonViKPI'],
        tenDonViKPI: json['tenDonViKPI'],
        thang: (json['thang'] as num?)?.toInt(),
        nam: (json['nam'] as num?)?.toInt(),
        chuKy: (json['chuKy'] as num?)?.toInt(),
        kyQuy: (json['kyQuy'] as num?)?.toInt(),
        thoiDiem: json['thoiDiem'],
        diemCong: json['diemCong'] as num?,
        diemKetQua: json['diemKetQua'] as num?,
        diemKetQuaTamThoi: json['diemKetQuaTamThoi'] as num?,
        diemKetQuaTuDanhGia: json['diemKetQuaTuDanhGia'] as num?,
        diemKetQuaCuoiCung: json['diemKetQuaCuoiCung'] as num?,
        diemTru: json['diemTru'] as num?,
        nhanXetDanhGia1: json['nhanXetDanhGia1'],
        nhanXetDanhGia2: json['nhanXetDanhGia2'],
        nhanXetDanhGia3: json['nhanXetDanhGia3'],
        nhanXetDanhGia4: json['nhanXetDanhGia4'],
        nhanXetDanhGia5: json['nhanXetDanhGia5'],
        isThucHienDanhGia: _toBool(json['isThucHienDanhGia']),
        capDoNhanSu: json['capDoNhanSu'],
        trangThai: (json['trangThai'] as num?)?.toInt(),
        isThucHienDuyetKpiCvDv: _toBool(json['isThucHienDuyetKPICVDV']),
        isUyQuyen: _toBool(json['isUyQuyen']),
        isThucHienTuDanhGia: _toBool(json['isThucHienTuDanhGia']),
        lyDoKhongDanhGiaId: json['vptq_kpi_LyDoKhongDanhGia_Id']?.toString(),
        maLyDoKhongDanhGia: json['maLyDoKhongDanhGia'],
        lyDoKhongDanhGia: json['lyDoKhongDanhGia'],
        isKhongDanhGia: _toBool(json['isKhongDanhGia']),
        isCvkpiTong: _toBool(json['isCVKPITong']),
        capDoNhanSuId: json['capDoNhanSu_Id']?.toString(),
        thangDiemXepLoaiChiTietId: json['vptq_kpi_ThangDiemXepLoaiChiTiet_Id']?.toString(),
        tenCapDoNhanSu: json['tenCapDoNhanSu'],
        xepLoai: json['xepLoai'],
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
        tenNguoiDuyetHienTai: json['tenNguoiDuyetHienTai'],
        maNguoiDuyetHienTai: json['maNguoiDuyetHienTai'],
        isDaXem: _toBool(json['isDaXem']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDongDanhGia': isDongDanhGia,
        'isDong': isDong,
        'isLanhDaoTiemNang': isLanhDaoTiemNang,
        'isLanhDaoDonVi': isLanhDaoDonVi,
        'isHoanThanhDanhGia': isHoanThanhDanhGia,
        'isTraLaiDanhGia': isTraLaiDanhGia,
        'isCoQuyenChuyenVienKPI': isCoQuyenChuyenVienKPI,
        'isHoanThanh': isHoanThanh,
        'isThucHienChinhSuaCVKPI': isThucHienChinhSuaCVKPI,
        'viTriDuyet': viTriDuyet,
        'nhiemVu': nhiemVu,
        'viTriDuyetDanhGia': viTriDuyetDanhGia,
        'ngayTao': ngayTao,
        'thoiGianHoanThanh': thoiGianHoanThanh,
        'user_Id': user_Id,
        'nguoiTao_Id': nguoiTaoId,
        'nguoiDuyetDanhGia1_Id': nguoiDuyetDanhGia1Id,
        'nguoiDuyetDanhGia2_Id': nguoiDuyetDanhGia2Id,
        'nguoiDuyetDanhGia3_Id': nguoiDuyetDanhGia3Id,
        'nguoiDuyetDanhGia4_Id': nguoiDuyetDanhGia4Id,
        'nguoiDuyetDanhGia5_Id': nguoiDuyetDanhGia5Id,
        'nguoiDuyetDanhGiaHienTai_Id': nguoiDuyetDanhGiaHienTaiId,
        'nguoiDuyet1_Id': nguoiDuyetDanhGia1Id,
        'nguoiDuyet2_Id': nguoiDuyetDanhGia2Id,
        'nguoiDuyet3_Id': nguoiDuyetDanhGia3Id,
        'nguoiDuyet4_Id': nguoiDuyetDanhGia4Id,
        'nguoiDuyet5_Id': nguoiDuyetDanhGia5Id,
        'nguoiDuyetHienTai_Id': nguoiDuyetDanhGiaHienTaiId,
        'tenUser': tenUser,
        'maUser': maUser,
        'tenNguoiTao': tenNguoiTao,
        'maNguoiTao': maNguoiTao,
        'chucDanh_Id': chucDanhId,
        'chucVu_Id': chucVuId,
        'phongBanThaco_Id': phongBanThacoId,
        'vptq_kpi_DonViKPI_Id': vptqKpiDonViKpiId,
        'vptq_kpi_KyDanhGiaKPI_Id': vptqKpiKyDanhGiaKpiId,
        'tenChucDanh': tenChucDanh,
        'maChucDanh': maChucDanh,
        'tenChucVu': tenChucVu,
        'tenPhongBan': tenPhongBan,
        'maDonViKPI': maDonViKPI,
        'tenDonViKPI': tenDonViKPI,
        'thang': thang,
        'nam': nam,
        'chuKy': chuKy,
        'kyQuy': kyQuy,
        'thoiDiem': thoiDiem,
        'diemCong': diemCong,
        'diemKetQua': diemKetQua,
        'diemKetQuaTamThoi': diemKetQuaTamThoi,
        'diemKetQuaTuDanhGia': diemKetQuaTuDanhGia,
        'diemKetQuaCuoiCung': diemKetQuaCuoiCung,
        'diemTru': diemTru,
        'nhanXetDanhGia1': nhanXetDanhGia1,
        'nhanXetDanhGia2': nhanXetDanhGia2,
        'nhanXetDanhGia3': nhanXetDanhGia3,
        'nhanXetDanhGia4': nhanXetDanhGia4,
        'nhanXetDanhGia5': nhanXetDanhGia5,
        'isThucHienDanhGia': isThucHienDanhGia,
        'capDoNhanSu': capDoNhanSu,
        'trangThai': trangThai,
        'isThucHienDuyetKPICVDV': isThucHienDuyetKpiCvDv,
        'isUyQuyen': isUyQuyen,
        'isThucHienTuDanhGia': isThucHienTuDanhGia,
        'vptq_kpi_LyDoKhongDanhGia_Id': lyDoKhongDanhGiaId,
        'maLyDoKhongDanhGia': maLyDoKhongDanhGia,
        'lyDoKhongDanhGia': lyDoKhongDanhGia,
        'isKhongDanhGia': isKhongDanhGia,
        'isCVKPITong': isCvkpiTong,
        'capDoNhanSu_Id': capDoNhanSuId,
        'vptq_kpi_ThangDiemXepLoaiChiTiet_Id': thangDiemXepLoaiChiTietId,
        'tenCapDoNhanSu': tenCapDoNhanSu,
        'xepLoai': xepLoai,
        'isDaXem': isDaXem,
      };

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    return v.toString().toLowerCase() == 'true';
  }
}
