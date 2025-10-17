class GiaoKPIModel {
  String? id;
  bool? isLanhDaoTiemNang;
  bool? isLanhDaoDonVi;
  bool? isHoanThanh;
  bool? isTraLai;
  int? viTriDuyet;
  String? nhiemVu;
  String? nguoiTaoId;
  String? tenNguoiTao;
  String? userId;
  String? tenUser;
  String? maUser;
  String? ngayTao; // giữ String
  String? thoiGianHoanThanh; // giữ String
  String? nguoiDuyetHienTaiId;
  String? tenNguoiDuyetHienTai;
  String? maNguoiDuyetHienTai;
  String? nguoiDuyet1Id;
  String? tenNguoiDuyet1;
  String? maNguoiDuyet1;
  String? nguoiDuyet2Id;
  String? tenNguoiDuyet2;
  String? maNguoiDuyet2;
  String? nguoiDuyet3Id;
  String? tenNguoiDuyet3;
  String? maNguoiDuyet3;
  String? nguoiDuyet4Id;
  String? tenNguoiDuyet4;
  String? maNguoiDuyet4;
  String? nguoiDuyet5Id;
  String? tenNguoiDuyet5;
  String? maNguoiDuyet5;
  String? chucDanhId;
  String? tenChucDanh;
  String? chucVuId;
  String? tenChucVu;
  String? phongBanThacoId;
  String? maPhongBan;
  String? tenPhongBan;
  String? vptqKpiDonViKpiId;
  String? maDonViKpi;
  String? tenDonViKpi;
  String? vptqKpiKyDanhGiaKpiId;
  int? chuKy;
  bool? isDong;
  String? thoiDiem;
  int? thang;
  int? nam;
  int? kyQuy;
  bool? isThucHienChinhSuaCVKPI;
  int? trangThai;
  bool? isThucHienDuyetKPICVDV;

  List<KiemNhiem>? kiemNhiems;

  GiaoKPIModel({
    this.id,
    this.isLanhDaoTiemNang,
    this.isLanhDaoDonVi,
    this.isHoanThanh,
    this.isTraLai,
    this.viTriDuyet,
    this.nhiemVu,
    this.nguoiTaoId,
    this.tenNguoiTao,
    this.userId,
    this.tenUser,
    this.maUser,
    this.ngayTao,
    this.thoiGianHoanThanh,
    this.nguoiDuyetHienTaiId,
    this.tenNguoiDuyetHienTai,
    this.maNguoiDuyetHienTai,
    this.nguoiDuyet1Id,
    this.tenNguoiDuyet1,
    this.maNguoiDuyet1,
    this.nguoiDuyet2Id,
    this.tenNguoiDuyet2,
    this.maNguoiDuyet2,
    this.nguoiDuyet3Id,
    this.tenNguoiDuyet3,
    this.maNguoiDuyet3,
    this.nguoiDuyet4Id,
    this.tenNguoiDuyet4,
    this.maNguoiDuyet4,
    this.nguoiDuyet5Id,
    this.tenNguoiDuyet5,
    this.maNguoiDuyet5,
    this.chucDanhId,
    this.tenChucDanh,
    this.chucVuId,
    this.tenChucVu,
    this.phongBanThacoId,
    this.maPhongBan,
    this.tenPhongBan,
    this.vptqKpiDonViKpiId,
    this.maDonViKpi,
    this.tenDonViKpi,
    this.vptqKpiKyDanhGiaKpiId,
    this.chuKy,
    this.isDong,
    this.thoiDiem,
    this.thang,
    this.nam,
    this.kyQuy,
    this.isThucHienChinhSuaCVKPI,
    this.trangThai,
    this.isThucHienDuyetKPICVDV,
    this.kiemNhiems,
  });

  factory GiaoKPIModel.fromJson(Map<String, dynamic> json) => GiaoKPIModel(
        id: json['id'],
        isLanhDaoTiemNang: json['isLanhDaoTiemNang'],
        isLanhDaoDonVi: json['isLanhDaoDonVi'],
        isHoanThanh: json['isHoanThanh'],
        isTraLai: json['isTraLai'],
        viTriDuyet: json['viTriDuyet'],
        nhiemVu: json['nhiemVu'],
        nguoiTaoId: json['nguoiTao_Id'],
        tenNguoiTao: json['tenNguoiTao'],
        userId: json['user_Id'],
        tenUser: json['tenUser'],
        maUser: json['maUser'],
        ngayTao: json['ngayTao'],
        thoiGianHoanThanh: json['thoiGianHoanThanh'],
        nguoiDuyetHienTaiId: json['nguoiDuyetHienTai_Id'],
        tenNguoiDuyetHienTai: json['tenNguoiDuyetHienTai'],
        maNguoiDuyetHienTai: json['maNguoiDuyetHienTai'],
        nguoiDuyet1Id: json['nguoiDuyet1_Id'],
        tenNguoiDuyet1: json['tenNguoiDuyet1'],
        maNguoiDuyet1: json['maNguoiDuyet1'],
        nguoiDuyet2Id: json['nguoiDuyet2_Id'],
        tenNguoiDuyet2: json['tenNguoiDuyet2'],
        maNguoiDuyet2: json['maNguoiDuyet2'],
        nguoiDuyet3Id: json['nguoiDuyet3_Id'],
        tenNguoiDuyet3: json['tenNguoiDuyet3'],
        maNguoiDuyet3: json['maNguoiDuyet3'],
        nguoiDuyet4Id: json['nguoiDuyet4_Id'],
        tenNguoiDuyet4: json['tenNguoiDuyet4'],
        maNguoiDuyet4: json['maNguoiDuyet4'],
        nguoiDuyet5Id: json['nguoiDuyet5_Id'],
        tenNguoiDuyet5: json['tenNguoiDuyet5'],
        maNguoiDuyet5: json['maNguoiDuyet5'],
        chucDanhId: json['chucDanh_Id'],
        tenChucDanh: json['tenChucDanh'],
        chucVuId: json['chucVu_Id'],
        tenChucVu: json['tenChucVu'],
        phongBanThacoId: json['phongBanThaco_Id'],
        maPhongBan: json['maPhongBan'],
        tenPhongBan: json['tenPhongBan'],
        vptqKpiDonViKpiId: json['vptq_kpi_DonViKPI_Id'],
        maDonViKpi: json['maDonViKPI'],
        tenDonViKpi: json['tenDonViKPI'],
        vptqKpiKyDanhGiaKpiId: json['vptq_kpi_KyDanhGiaKPI_Id'],
        chuKy: json['chuKy'],
        isDong: json['isDong'],
        thoiDiem: json['thoiDiem'],
        thang: json['thang'],
        nam: json['nam'],
        kyQuy: json['kyQuy'],
        isThucHienChinhSuaCVKPI: json['isThucHienChinhSuaCVKPI'],
        trangThai: json['trangThai'],
        isThucHienDuyetKPICVDV: json['isThucHienDuyetKPICVDV'],
        kiemNhiems: (json['kiemNhiems'] as List?)?.map((e) => KiemNhiem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isLanhDaoTiemNang': isLanhDaoTiemNang,
        'isLanhDaoDonVi': isLanhDaoDonVi,
        'isHoanThanh': isHoanThanh,
        'isTraLai': isTraLai,
        'viTriDuyet': viTriDuyet,
        'nhiemVu': nhiemVu,
        'nguoiTao_Id': nguoiTaoId,
        'tenNguoiTao': tenNguoiTao,
        'user_Id': userId,
        'tenUser': tenUser,
        'maUser': maUser,
        'ngayTao': ngayTao,
        'thoiGianHoanThanh': thoiGianHoanThanh,
        'nguoiDuyetHienTai_Id': nguoiDuyetHienTaiId,
        'tenNguoiDuyetHienTai': tenNguoiDuyetHienTai,
        'maNguoiDuyetHienTai': maNguoiDuyetHienTai,
        'nguoiDuyet1_Id': nguoiDuyet1Id,
        'tenNguoiDuyet1': tenNguoiDuyet1,
        'maNguoiDuyet1': maNguoiDuyet1,
        'nguoiDuyet2_Id': nguoiDuyet2Id,
        'tenNguoiDuyet2': tenNguoiDuyet2,
        'maNguoiDuyet2': maNguoiDuyet2,
        'nguoiDuyet3_Id': nguoiDuyet3Id,
        'tenNguoiDuyet3': tenNguoiDuyet3,
        'maNguoiDuyet3': maNguoiDuyet3,
        'nguoiDuyet4_Id': nguoiDuyet4Id,
        'tenNguoiDuyet4': tenNguoiDuyet4,
        'maNguoiDuyet4': maNguoiDuyet4,
        'nguoiDuyet5_Id': nguoiDuyet5Id,
        'tenNguoiDuyet5': tenNguoiDuyet5,
        'maNguoiDuyet5': maNguoiDuyet5,
        'chucDanh_Id': chucDanhId,
        'tenChucDanh': tenChucDanh,
        'chucVu_Id': chucVuId,
        'tenChucVu': tenChucVu,
        'phongBanThaco_Id': phongBanThacoId,
        'maPhongBan': maPhongBan,
        'tenPhongBan': tenPhongBan,
        'vptq_kpi_DonViKPI_Id': vptqKpiDonViKpiId,
        'maDonViKPI': maDonViKpi,
        'tenDonViKPI': tenDonViKpi,
        'vptq_kpi_KyDanhGiaKPI_Id': vptqKpiKyDanhGiaKpiId,
        'chuKy': chuKy,
        'isDong': isDong,
        'thoiDiem': thoiDiem,
        'thang': thang,
        'nam': nam,
        'kyQuy': kyQuy,
        'isThucHienChinhSuaCVKPI': isThucHienChinhSuaCVKPI,
        'trangThai': trangThai,
        'isThucHienDuyetKPICVDV': isThucHienDuyetKPICVDV,
        'kiemNhiems': kiemNhiems?.map((e) => e.toJson()).toList(),
      };
}

class KiemNhiem {
  String? vptqKpiKpiCaNhanKiemNhiemId;
  String? vptqKpiDonViKpiId;
  String? chucDanhId;
  String? chucVuId;
  String? phongBanThacoId;
  String? tenDonViKpi;
  String? tenPhongBan;
  String? tenChucDanh;
  String? tenChucVu;
  String? nhiemVu;
  num? tyTrong;
  List<NhomPIModel>? nhomPIs;
  List<KpiCaNhanNhomPI>? kpiCaNhanNhomPIs;

  KiemNhiem({
    this.vptqKpiKpiCaNhanKiemNhiemId,
    this.vptqKpiDonViKpiId,
    this.chucDanhId,
    this.chucVuId,
    this.phongBanThacoId,
    this.tenDonViKpi,
    this.tenPhongBan,
    this.tenChucDanh,
    this.tenChucVu,
    this.nhiemVu,
    this.tyTrong,
    this.nhomPIs,
    this.kpiCaNhanNhomPIs,
  });

  factory KiemNhiem.fromJson(Map<String, dynamic> json) => KiemNhiem(
        vptqKpiKpiCaNhanKiemNhiemId: json['vptq_kpi_KPICaNhanKiemNhiem_Id'],
        vptqKpiDonViKpiId: json['vptq_kpi_DonViKPI_Id'],
        chucDanhId: json['chucDanh_Id'],
        chucVuId: json['chucVu_Id'],
        phongBanThacoId: json['phongBanThaco_Id'],
        tenDonViKpi: json['tenDonViKPI'],
        tenPhongBan: json['tenPhongBan'],
        tenChucDanh: json['tenChucDanh'],
        tenChucVu: json['tenChucVu'],
        nhiemVu: json['nhiemVu'],
        tyTrong: json['tyTrong'],
        nhomPIs: (json['nhomPIs'] as List?)?.map((e) => NhomPIModel.fromJson(e as Map<String, dynamic>)).toList(),
        kpiCaNhanNhomPIs: (json['kpiCaNhanNhomPIs'] as List?)?.map((e) => KpiCaNhanNhomPI.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_KPICaNhanKiemNhiem_Id': vptqKpiKpiCaNhanKiemNhiemId,
        'vptq_kpi_DonViKPI_Id': vptqKpiDonViKpiId,
        'chucDanh_Id': chucDanhId,
        'chucVu_Id': chucVuId,
        'phongBanThaco_Id': phongBanThacoId,
        'tenDonViKPI': tenDonViKpi,
        'tenPhongBan': tenPhongBan,
        'tenChucDanh': tenChucDanh,
        'tenChucVu': tenChucVu,
        'nhiemVu': nhiemVu,
        'tyTrong': tyTrong,
        'nhomPIs': nhomPIs?.map((e) => e.toJson()).toList(),
        'kpiCaNhanNhomPIs': kpiCaNhanNhomPIs?.map((e) => e.toJson()).toList(),
      };
}

class NhomPIModel {
  String? vptqKpiKpiCaNhanKiemNhiemId;
  String? vptqKpiNhomPIId;
  String? tenNhomPI;
  int? thuTuNhom;
  num? tyTrongNhomPI;
  int? toanTu;
  bool? isBatBuocDung;
  bool? isChoPhepBang0;
  num? tongTyTrong;
  List<ChiTietPIModel>? chiTiets;

  NhomPIModel({
    this.vptqKpiKpiCaNhanKiemNhiemId,
    this.vptqKpiNhomPIId,
    this.tenNhomPI,
    this.thuTuNhom,
    this.tyTrongNhomPI,
    this.toanTu,
    this.isBatBuocDung,
    this.isChoPhepBang0,
    this.tongTyTrong,
    this.chiTiets,
  });

  factory NhomPIModel.fromJson(Map<String, dynamic> json) => NhomPIModel(
        vptqKpiKpiCaNhanKiemNhiemId: json['vptq_kpi_KPICaNhanKiemNhiem_Id'],
        vptqKpiNhomPIId: json['vptq_kpi_NhomPI_Id'],
        tenNhomPI: json['tenNhomPI'],
        thuTuNhom: json['thuTuNhom'],
        tyTrongNhomPI: json['tyTrongNhomPI'],
        toanTu: json['toanTu'],
        isBatBuocDung: json['isBatBuocDung'],
        isChoPhepBang0: json['isChoPhepBang0'],
        tongTyTrong: json['tongTyTrong'],
        chiTiets: (json['chiTiets'] as List?)?.map((e) => ChiTietPIModel.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_KPICaNhanKiemNhiem_Id': vptqKpiKpiCaNhanKiemNhiemId,
        'vptq_kpi_NhomPI_Id': vptqKpiNhomPIId,
        'tenNhomPI': tenNhomPI,
        'thuTuNhom': thuTuNhom,
        'tyTrongNhomPI': tyTrongNhomPI,
        'toanTu': toanTu,
        'isBatBuocDung': isBatBuocDung,
        'isChoPhepBang0': isChoPhepBang0,
        'tongTyTrong': tongTyTrong,
        'chiTiets': chiTiets?.map((e) => e.toJson()).toList(),
      };
}

class ChiTietPIModel {
  String? vptqKpiKpiCaNhanChiTietId;
  num? tyTrong;
  int? thuTu;
  num? giaTriChiTieu;
  String? noiDungChiTieu;
  String? vptqKpiDanhMucPiDanhMucPiChiTietId;
  String? vptqKpiDanhMucPiChiTietPhienBanId;
  String? vptqKpiKpiCaNhanId;
  String? vptqKpiNhomPIId;
  String? dienGiai;
  String? vptqKpiDanhMucPiChiTietId;
  String? maSoPI;
  String? chiSoDanhGia;
  String? chiSoDanhGiaChiTiet;
  String? tenDonViTinh;
  bool? isNoiDung;
  bool? isTang;
  bool? isKetQuaThucHien;
  List<ChiTietPICon>? chiTietCons;

  ChiTietPIModel({
    this.vptqKpiKpiCaNhanChiTietId,
    this.tyTrong,
    this.thuTu,
    this.giaTriChiTieu,
    this.noiDungChiTieu,
    this.vptqKpiDanhMucPiDanhMucPiChiTietId,
    this.vptqKpiDanhMucPiChiTietPhienBanId,
    this.vptqKpiKpiCaNhanId,
    this.vptqKpiNhomPIId,
    this.dienGiai,
    this.vptqKpiDanhMucPiChiTietId,
    this.maSoPI,
    this.chiSoDanhGia,
    this.chiSoDanhGiaChiTiet,
    this.tenDonViTinh,
    this.isNoiDung,
    this.isTang,
    this.isKetQuaThucHien,
    this.chiTietCons,
  });

  factory ChiTietPIModel.fromJson(Map<String, dynamic> json) => ChiTietPIModel(
        vptqKpiKpiCaNhanChiTietId: json['vptq_kpi_KPICaNhanChiTiet_Id'],
        tyTrong: json['tyTrong'],
        thuTu: json['thuTu'],
        giaTriChiTieu: json['giaTriChiTieu'],
        noiDungChiTieu: json['noiDungChiTieu'],
        vptqKpiDanhMucPiDanhMucPiChiTietId: json['vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id'],
        vptqKpiDanhMucPiChiTietPhienBanId: json['vptq_kpi_DanhMucPIChiTietPhienBan_Id'],
        vptqKpiKpiCaNhanId: json['vptq_kpi_KPICaNhan_Id'],
        vptqKpiNhomPIId: json['vptq_kpi_NhomPI_Id'],
        dienGiai: json['dienGiai'],
        vptqKpiDanhMucPiChiTietId: json['vptq_kpi_DanhMucPIChiTiet_Id'],
        maSoPI: json['maSoPI'],
        chiSoDanhGia: json['chiSoDanhGia'],
        chiSoDanhGiaChiTiet: json['chiSoDanhGiaChiTiet'],
        tenDonViTinh: json['tenDonViTinh'],
        isNoiDung: json['isNoiDung'],
        isTang: json['isTang'],
        isKetQuaThucHien: json['isKetQuaThucHien'],
        chiTietCons: (json['chiTietCons'] as List?)?.map((e) => ChiTietPICon.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_KPICaNhanChiTiet_Id': vptqKpiKpiCaNhanChiTietId,
        'tyTrong': tyTrong,
        'thuTu': thuTu,
        'giaTriChiTieu': giaTriChiTieu,
        'noiDungChiTieu': noiDungChiTieu,
        'vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id': vptqKpiDanhMucPiDanhMucPiChiTietId,
        'vptq_kpi_DanhMucPIChiTietPhienBan_Id': vptqKpiDanhMucPiChiTietPhienBanId,
        'vptq_kpi_KPICaNhan_Id': vptqKpiKpiCaNhanId,
        'vptq_kpi_NhomPI_Id': vptqKpiNhomPIId,
        'dienGiai': dienGiai,
        'vptq_kpi_DanhMucPIChiTiet_Id': vptqKpiDanhMucPiChiTietId,
        'maSoPI': maSoPI,
        'chiSoDanhGia': chiSoDanhGia,
        'chiSoDanhGiaChiTiet': chiSoDanhGiaChiTiet,
        'tenDonViTinh': tenDonViTinh,
        'isNoiDung': isNoiDung,
        'isTang': isTang,
        'isKetQuaThucHien': isKetQuaThucHien,
        'chiTietCons': chiTietCons?.map((e) => e.toJson()).toList(),
      };
}

class ChiTietPICon {
  String? vptqKpiKpiCaNhanChiTietConId;
  num? tyTrong;
  String? dienGiai;
  int? thuTu;
  String? noiDungChiTieu;
  num? giaTriChiTieu;
  String? vptqKpiDanhMucPiChiTietPhienBanConId;
  String? vptqKpiDanhMucPiChiTietPhienBanId;
  String? maSoPI;
  String? chiSoDanhGia;
  String? chiSoDanhGiaChiTiet;
  String? vptqKpiKpiCaNhanChiTietId;
  String? vptqKpiKpiCaNhanId;
  String? tenDonViTinh;
  bool? isNoiDung;
  bool? isTang;
  bool? isKetQuaThucHien;

  ChiTietPICon({
    this.vptqKpiKpiCaNhanChiTietConId,
    this.tyTrong,
    this.dienGiai,
    this.thuTu,
    this.noiDungChiTieu,
    this.giaTriChiTieu,
    this.vptqKpiDanhMucPiChiTietPhienBanConId,
    this.vptqKpiDanhMucPiChiTietPhienBanId,
    this.maSoPI,
    this.chiSoDanhGia,
    this.chiSoDanhGiaChiTiet,
    this.vptqKpiKpiCaNhanChiTietId,
    this.vptqKpiKpiCaNhanId,
    this.tenDonViTinh,
    this.isNoiDung,
    this.isTang,
    this.isKetQuaThucHien,
  });

  factory ChiTietPICon.fromJson(Map<String, dynamic> json) => ChiTietPICon(
        vptqKpiKpiCaNhanChiTietConId: json['vptq_kpi_KPICaNhanChiTietCon_Id'],
        tyTrong: json['tyTrong'],
        dienGiai: json['dienGiai'],
        thuTu: json['thuTu'],
        noiDungChiTieu: json['noiDungChiTieu'],
        giaTriChiTieu: json['giaTriChiTieu'],
        vptqKpiDanhMucPiChiTietPhienBanConId: json['vptq_kpi_DanhMucPIChiTietPhienBanCon_Id'],
        maSoPI: json['maSoPI'],
        chiSoDanhGia: json['chiSoDanhGia'],
        chiSoDanhGiaChiTiet: json['chiSoDanhGiaChiTiet'],
        vptqKpiKpiCaNhanChiTietId: json['vptq_kpi_KPICaNhanChiTiet_Id'],
        vptqKpiDanhMucPiChiTietPhienBanId: json['vptqKpiDanhMucPiChiTietPhienBanId'],
        vptqKpiKpiCaNhanId: json['vptq_kpi_KPICaNhan_Id'],
        tenDonViTinh: json['tenDonViTinh'],
        isNoiDung: json['isNoiDung'],
        isTang: json['isTang'],
        isKetQuaThucHien: json['isKetQuaThucHien'],
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_KPICaNhanChiTietCon_Id': vptqKpiKpiCaNhanChiTietConId,
        'tyTrong': tyTrong,
        'dienGiai': dienGiai,
        'thuTu': thuTu,
        'noiDungChiTieu': noiDungChiTieu,
        'giaTriChiTieu': giaTriChiTieu,
        'vptq_kpi_DanhMucPIChiTietPhienBanCon_Id': vptqKpiDanhMucPiChiTietPhienBanConId,
        'vptqKpiDanhMucPiChiTietPhienBanId': vptqKpiDanhMucPiChiTietPhienBanId,
        'maSoPI': maSoPI,
        'chiSoDanhGia': chiSoDanhGia,
        'chiSoDanhGiaChiTiet': chiSoDanhGiaChiTiet,
        'vptq_kpi_KPICaNhanChiTiet_Id': vptqKpiKpiCaNhanChiTietId,
        'vptq_kpi_KPICaNhan_Id': vptqKpiKpiCaNhanId,
        'tenDonViTinh': tenDonViTinh,
        'isNoiDung': isNoiDung,
        'isTang': isTang,
        'isKetQuaThucHien': isKetQuaThucHien,
      };
}

class KpiCaNhanNhomPI {
  String? vptqKpiKpiCaNhanKiemNhiemId;
  String? vptq_kpi_NhomPI_Id;
  String? tenNhomPI;
  num? tyTrongNhomPI;
  int? toanTu;
  bool? isBatBuocDung;
  bool? isChoPhepBang0;
  int? thuTuNhom;
  List<KpiCaNhanNhomPIChiTiet>? chiTiets;

  KpiCaNhanNhomPI({
    this.vptqKpiKpiCaNhanKiemNhiemId,
    this.vptq_kpi_NhomPI_Id,
    this.tenNhomPI,
    this.tyTrongNhomPI,
    this.toanTu,
    this.isBatBuocDung,
    this.isChoPhepBang0,
    this.thuTuNhom,
    this.chiTiets,
  });

  factory KpiCaNhanNhomPI.fromJson(Map<String, dynamic> json) => KpiCaNhanNhomPI(
        vptqKpiKpiCaNhanKiemNhiemId: json['vptq_kpi_KPICaNhanKiemNhiem_Id'],
        vptq_kpi_NhomPI_Id: json['vptq_kpi_NhomPI_Id'],
        tenNhomPI: json['tenNhomPI'],
        tyTrongNhomPI: json['tyTrongNhomPI'],
        toanTu: json['toanTu'],
        isBatBuocDung: json['isBatBuocDung'],
        isChoPhepBang0: json['isChoPhepBang0'],
        thuTuNhom: json['thuTuNhom'],
        chiTiets: (json['chiTiets'] as List?)?.map((e) => KpiCaNhanNhomPIChiTiet.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_KPICaNhanKiemNhiem_Id': vptqKpiKpiCaNhanKiemNhiemId,
        'vptq_kpi_NhomPI_Id': vptq_kpi_NhomPI_Id,
        'tenNhomPI': tenNhomPI,
        'tyTrongNhomPI': tyTrongNhomPI,
        'toanTu': toanTu,
        'isBatBuocDung': isBatBuocDung,
        'isChoPhepBang0': isChoPhepBang0,
        'thuTuNhom': thuTuNhom,
        'chiTiets': chiTiets?.map((e) => e.toJson()).toList(),
      };
}

class KpiCaNhanNhomPIChiTiet {
  String? vptqKpiDanhMucPiDanhMucPiChiTietId;
  String? vptqKpiDanhMucPiId;
  String? vptqKpiDanhMucPiChiTietId;
  String? vptqKpiDanhMucPiChiTietPhienBanId;
  String? vptqKpiNhomPIId;
  int? chuKy;
  String? maSoPI;
  int? thuTuMa;
  String? chiSoDanhGia;
  String? chiSoDanhGiaChiTiet;
  String? tenDonViTinh;
  bool? isNoiDung;
  bool? isTang;
  bool? isKetQuaThucHien;
  bool? hasCon;
  bool? isTong;
  bool? isPICopyNgungSuDung;
  List<KpiCaNhanNhomPIChiTietCon>? chiTietCons;

  KpiCaNhanNhomPIChiTiet({
    this.vptqKpiDanhMucPiDanhMucPiChiTietId,
    this.vptqKpiDanhMucPiId,
    this.vptqKpiDanhMucPiChiTietId,
    this.vptqKpiDanhMucPiChiTietPhienBanId,
    this.vptqKpiNhomPIId,
    this.chuKy,
    this.maSoPI,
    this.thuTuMa,
    this.chiSoDanhGia,
    this.chiSoDanhGiaChiTiet,
    this.tenDonViTinh,
    this.isNoiDung,
    this.isTang,
    this.isKetQuaThucHien,
    this.hasCon,
    this.isTong,
    this.isPICopyNgungSuDung,
    this.chiTietCons,
  });

  factory KpiCaNhanNhomPIChiTiet.fromJson(Map<String, dynamic> json) => KpiCaNhanNhomPIChiTiet(
        vptqKpiDanhMucPiDanhMucPiChiTietId: json['vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id'],
        vptqKpiDanhMucPiId: json['vptq_kpi_DanhMucPI_Id'],
        vptqKpiDanhMucPiChiTietId: json['vptq_kpi_DanhMucPIChiTiet_Id'],
        vptqKpiDanhMucPiChiTietPhienBanId: json['vptq_kpi_DanhMucPIChiTietPhienBan_Id'],
        vptqKpiNhomPIId: json['vptq_kpi_NhomPI_Id'],
        chuKy: json['chuKy'],
        maSoPI: json['maSoPI'],
        thuTuMa: json['thuTuMa'],
        chiSoDanhGia: json['chiSoDanhGia'],
        chiSoDanhGiaChiTiet: json['chiSoDanhGiaChiTiet'],
        tenDonViTinh: json['tenDonViTinh'],
        isNoiDung: json['isNoiDung'],
        isTang: json['isTang'],
        isKetQuaThucHien: json['isKetQuaThucHien'],
        hasCon: json['hasCon'],
        isTong: json['isTong'],
        isPICopyNgungSuDung: json['isPICopyNgungSuDung'],
        chiTietCons: (json['chiTietCons'] as List?)?.map((e) => KpiCaNhanNhomPIChiTietCon.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id': vptqKpiDanhMucPiDanhMucPiChiTietId,
        'vptq_kpi_DanhMucPI_Id': vptqKpiDanhMucPiId,
        'vptq_kpi_DanhMucPIChiTiet_Id': vptqKpiDanhMucPiChiTietId,
        'vptq_kpi_DanhMucPIChiTietPhienBan_Id': vptqKpiDanhMucPiChiTietPhienBanId,
        'vptq_kpi_NhomPI_Id': vptqKpiNhomPIId,
        'chuKy': chuKy,
        'maSoPI': maSoPI,
        'thuTuMa': thuTuMa,
        'chiSoDanhGia': chiSoDanhGia,
        'chiSoDanhGiaChiTiet': chiSoDanhGiaChiTiet,
        'tenDonViTinh': tenDonViTinh,
        'isNoiDung': isNoiDung,
        'isTang': isTang,
        'isKetQuaThucHien': isKetQuaThucHien,
        'hasCon': hasCon,
        'isTong': isTong,
        'isPICopyNgungSuDung': isPICopyNgungSuDung,
        'chiTietCons': chiTietCons?.map((e) => e.toJson()).toList(),
      };
}

class KpiCaNhanNhomPIChiTietCon {
  String? vptqKpiDanhMucPiChiTietPhienBanConId;
  String? maSoPI;
  String? vptqKpiDanhMucPiChiTietPhienBanId;
  String? chiSoDanhGia;
  String? chiSoDanhGiaChiTiet;
  String? tenDonViTinh;
  int? thuTuMa;
  bool? isNoiDung;
  bool? isTang;
  bool? isKetQuaThucHien;

  KpiCaNhanNhomPIChiTietCon({
    this.vptqKpiDanhMucPiChiTietPhienBanConId,
    this.maSoPI,
    this.vptqKpiDanhMucPiChiTietPhienBanId,
    this.chiSoDanhGia,
    this.chiSoDanhGiaChiTiet,
    this.tenDonViTinh,
    this.thuTuMa,
    this.isNoiDung,
    this.isTang,
    this.isKetQuaThucHien,
  });

  factory KpiCaNhanNhomPIChiTietCon.fromJson(Map<String, dynamic> json) => KpiCaNhanNhomPIChiTietCon(
        vptqKpiDanhMucPiChiTietPhienBanConId: json['vptq_kpi_DanhMucPIChiTietPhienBanCon_Id'],
        maSoPI: json['maSoPI'],
        vptqKpiDanhMucPiChiTietPhienBanId: json['vptq_kpi_DanhMucPIChiTietPhienBan_Id'],
        chiSoDanhGia: json['chiSoDanhGia'],
        chiSoDanhGiaChiTiet: json['chiSoDanhGiaChiTiet'],
        tenDonViTinh: json['tenDonViTinh'],
        thuTuMa: json['thuTuMa'],
        isNoiDung: json['isNoiDung'],
        isTang: json['isTang'],
        isKetQuaThucHien: json['isKetQuaThucHien'],
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_DanhMucPIChiTietPhienBanCon_Id': vptqKpiDanhMucPiChiTietPhienBanConId,
        'maSoPI': maSoPI,
        'vptq_kpi_DanhMucPIChiTietPhienBan_Id': vptqKpiDanhMucPiChiTietPhienBanId,
        'chiSoDanhGia': chiSoDanhGia,
        'chiSoDanhGiaChiTiet': chiSoDanhGiaChiTiet,
        'tenDonViTinh': tenDonViTinh,
        'thuTuMa': thuTuMa,
        'isNoiDung': isNoiDung,
        'isTang': isTang,
        'isKetQuaThucHien': isKetQuaThucHien,
      };
}
