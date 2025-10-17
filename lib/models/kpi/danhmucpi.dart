class DanhMucPiModel {
  bool? isCoQuyen;
  bool? isChuyenVienPhongKPI;
  bool? isPITong;
  int? phienBan;
  String? apDungDen;
  String? apDungTu;
  String? apDungDenPhienBanTruoc;
  String? apDungTuPhienBanTruoc;
  int? soLuongPI;
  bool? isHoanThanh;
  String? id;
  bool? isTraLai;
  String? ngayTao;
  String? nguoiTao_Id;
  String? tenNguoiTao;
  String? maNguoiTao;
  String? vptq_kpi_DonViKPI_Id;
  String? maDonViKPI;
  String? tenDonViKPI;
  int? viTriDuyet;
  String? nguoiDuyetHienTai_Id;
  String? tenNguoiDuyetHienTai;
  String? maNguoiDuyetHienTai;
  String? pgdDuyet_Id;
  String? tenPGDDuyet;
  String? maPGDDuyet;
  int? trangThai;

  List<DanhMucPiChiTietModel>? chiTiets;
  List<NguoiDuyetPiModel>? nguoiDuyets;

  DanhMucPiModel({
    this.isCoQuyen,
    this.isChuyenVienPhongKPI,
    this.isPITong,
    this.phienBan,
    this.apDungDen,
    this.apDungTu,
    this.apDungDenPhienBanTruoc,
    this.apDungTuPhienBanTruoc,
    this.soLuongPI,
    this.isHoanThanh,
    this.id,
    this.isTraLai,
    this.ngayTao,
    this.nguoiTao_Id,
    this.tenNguoiTao,
    this.maNguoiTao,
    this.vptq_kpi_DonViKPI_Id,
    this.maDonViKPI,
    this.tenDonViKPI,
    this.viTriDuyet,
    this.nguoiDuyetHienTai_Id,
    this.tenNguoiDuyetHienTai,
    this.maNguoiDuyetHienTai,
    this.pgdDuyet_Id,
    this.tenPGDDuyet,
    this.maPGDDuyet,
    this.trangThai,
    this.chiTiets,
    this.nguoiDuyets,
  });

  factory DanhMucPiModel.fromJson(Map<String, dynamic> json) => DanhMucPiModel(
        isCoQuyen: json['isCoQuyen'] as bool?,
        isChuyenVienPhongKPI: json['isChuyenVienPhongKPI'] as bool?,
        isPITong: json['isPITong'] as bool?,
        phienBan: json['phienBan'] as int?,
        apDungDen: json['apDungDen'] as String?,
        apDungTu: json['apDungTu'] as String?,
        apDungDenPhienBanTruoc: json['apDungDenPhienBanTruoc'] as String?,
        apDungTuPhienBanTruoc: json['apDungTuPhienBanTruoc'] as String?,
        soLuongPI: json['soLuongPI'] as int?,
        isHoanThanh: json['isHoanThanh'] as bool?,
        id: json['id'] as String?,
        isTraLai: json['isTraLai'] as bool?,
        ngayTao: json['ngayTao'] as String?,
        nguoiTao_Id: json['nguoiTao_Id'] as String?,
        tenNguoiTao: json['tenNguoiTao'] as String?,
        maNguoiTao: json['maNguoiTao'] as String?,
        vptq_kpi_DonViKPI_Id: json['vptq_kpi_DonViKPI_Id'] as String?,
        maDonViKPI: json['maDonViKPI'] as String?,
        tenDonViKPI: json['tenDonViKPI'] as String?,
        viTriDuyet: json['viTriDuyet'] as int?,
        nguoiDuyetHienTai_Id: json['nguoiDuyetHienTai_Id'] as String?,
        tenNguoiDuyetHienTai: json['tenNguoiDuyetHienTai'] as String?,
        maNguoiDuyetHienTai: json['maNguoiDuyetHienTai'] as String?,
        pgdDuyet_Id: json['pgdDuyet_Id'] as String?,
        tenPGDDuyet: json['tenPGDDuyet'] as String?,
        maPGDDuyet: json['maPGDDuyet'] as String?,
        trangThai: json['trangThai'] as int?,
        chiTiets: (json['chiTiets'] as List?)?.map((e) => DanhMucPiChiTietModel.fromJson(e as Map<String, dynamic>)).toList(),
        nguoiDuyets: (json['nguoiDuyets'] as List?)?.map((e) => NguoiDuyetPiModel.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'isCoQuyen': isCoQuyen,
        'isChuyenVienPhongKPI': isChuyenVienPhongKPI,
        'isPITong': isPITong,
        'phienBan': phienBan,
        'apDungDen': apDungDen,
        'apDungTu': apDungTu,
        'apDungDenPhienBanTruoc': apDungDenPhienBanTruoc,
        'apDungTuPhienBanTruoc': apDungTuPhienBanTruoc,
        'soLuongPI': soLuongPI,
        'isHoanThanh': isHoanThanh,
        'id': id,
        'isTraLai': isTraLai,
        'ngayTao': ngayTao,
        'nguoiTao_Id': nguoiTao_Id,
        'tenNguoiTao': tenNguoiTao,
        'maNguoiTao': maNguoiTao,
        'vptq_kpi_DonViKPI_Id': vptq_kpi_DonViKPI_Id,
        'maDonViKPI': maDonViKPI,
        'tenDonViKPI': tenDonViKPI,
        'viTriDuyet': viTriDuyet,
        'nguoiDuyetHienTai_Id': nguoiDuyetHienTai_Id,
        'tenNguoiDuyetHienTai': tenNguoiDuyetHienTai,
        'maNguoiDuyetHienTai': maNguoiDuyetHienTai,
        'pgdDuyet_Id': pgdDuyet_Id,
        'tenPGDDuyet': tenPGDDuyet,
        'maPGDDuyet': maPGDDuyet,
        'trangThai': trangThai,
        'chiTiets': chiTiets?.map((e) => e.toJson()).toList(),
        'nguoiDuyets': nguoiDuyets?.map((e) => e.toJson()).toList(),
      };
}

class DanhMucPiChiTietModel {
  String? vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id;
  bool? isSuDung;
  bool? isCopy;
  String? vptq_kpi_DanhMucPI_Id;
  String? vptq_kpi_DanhMucPIChiTiet_Id;
  String? vptq_kpi_DanhMucPIChiTietPhienBanCon_Id;
  String? maSoPI;
  int? thuTuMa;
  String? chiSoDanhGia;
  int? chuKy;
  String? vptq_kpi_NhomPI_Id;
  String? maNhomPI;
  String? tenNhomPI;
  bool? isNoiDung;
  bool? isTang;
  bool? isKetQuaThucHien;
  String? vptq_kpi_DanhMucPIChiTietPhienBan_Id;
  int? phienBan;
  bool? hasCon;
  String? chiSoDanhGiaChiTiet;
  dynamic duLieuThamDinh;
  String? nguoiThamDinh_Id;
  String? tenNguoiThamDinh;
  String? maNguoiThamDinh;
  String? vptq_kpi_DonViTinh_Id;
  String? maDonViTinh;
  String? tenDonViTinh;

  List<MucTieuTrongYeuModel>? mucTieuTrongYeus;
  List<DanhMucPiChiTietModel>? chiTietCons;
  List<ChucDanhApDungModel>? chucDanhs;
  List<KetQuaDanhGiaModel>? ketQuas;

  bool? isKhongTonTaiHoacBanGocKhongSuDung;

  DanhMucPiChiTietModel({
    this.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id,
    this.isSuDung,
    this.isCopy,
    this.vptq_kpi_DanhMucPI_Id,
    this.vptq_kpi_DanhMucPIChiTiet_Id,
    this.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id,
    this.maSoPI,
    this.thuTuMa,
    this.chiSoDanhGia,
    this.chuKy,
    this.vptq_kpi_NhomPI_Id,
    this.maNhomPI,
    this.tenNhomPI,
    this.isNoiDung,
    this.isTang,
    this.isKetQuaThucHien,
    this.vptq_kpi_DanhMucPIChiTietPhienBan_Id,
    this.phienBan,
    this.hasCon,
    this.chiSoDanhGiaChiTiet,
    this.duLieuThamDinh,
    this.nguoiThamDinh_Id,
    this.tenNguoiThamDinh,
    this.maNguoiThamDinh,
    this.vptq_kpi_DonViTinh_Id,
    this.maDonViTinh,
    this.tenDonViTinh,
    this.mucTieuTrongYeus,
    this.chiTietCons,
    this.chucDanhs,
    this.ketQuas,
    this.isKhongTonTaiHoacBanGocKhongSuDung,
  });

  factory DanhMucPiChiTietModel.fromJson(Map<String, dynamic> json) => DanhMucPiChiTietModel(
        vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id: json['vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id'] as String?,
        isSuDung: json['isSuDung'] as bool?,
        isCopy: json['isCopy'] as bool?,
        vptq_kpi_DanhMucPI_Id: json['vptq_kpi_DanhMucPI_Id'] as String?,
        vptq_kpi_DanhMucPIChiTiet_Id: json['vptq_kpi_DanhMucPIChiTiet_Id'] as String?,
        vptq_kpi_DanhMucPIChiTietPhienBanCon_Id: json['vptq_kpi_DanhMucPIChiTietPhienBanCon_Id'] as String?,
        maSoPI: json['maSoPI'] as String?,
        thuTuMa: json['thuTuMa'] as int?,
        chiSoDanhGia: json['chiSoDanhGia'] as String?,
        chuKy: json['chuKy'] as int?,
        vptq_kpi_NhomPI_Id: json['vptq_kpi_NhomPI_Id'] as String?,
        maNhomPI: json['maNhomPI'] as String?,
        tenNhomPI: json['tenNhomPI'] as String?,
        isNoiDung: json['isNoiDung'] as bool?,
        isTang: json['isTang'] as bool?,
        isKetQuaThucHien: json['isKetQuaThucHien'] as bool?,
        vptq_kpi_DanhMucPIChiTietPhienBan_Id: json['vptq_kpi_DanhMucPIChiTietPhienBan_Id'] as String?,
        phienBan: json['phienBan'] as int?,
        hasCon: json['hasCon'] as bool?,
        chiSoDanhGiaChiTiet: json['chiSoDanhGiaChiTiet'] as String?,
        duLieuThamDinh: json['duLieuThamDinh'],
        nguoiThamDinh_Id: json['nguoiThamDinh_Id'] as String?,
        tenNguoiThamDinh: json['tenNguoiThamDinh'] as String?,
        maNguoiThamDinh: json['maNguoiThamDinh'] as String?,
        vptq_kpi_DonViTinh_Id: json['vptq_kpi_DonViTinh_Id'] as String?,
        maDonViTinh: json['maDonViTinh'] as String?,
        tenDonViTinh: json['tenDonViTinh'] as String?,
        mucTieuTrongYeus: (json['mucTieuTrongYeus'] as List?)?.map((e) => MucTieuTrongYeuModel.fromJson(e as Map<String, dynamic>)).toList(),
        chiTietCons: (json['chiTietCons'] as List?)?.map((e) => DanhMucPiChiTietModel.fromJson(e as Map<String, dynamic>)).toList(),
        chucDanhs: (json['chucDanhs'] as List?)?.map((e) => ChucDanhApDungModel.fromJson(e as Map<String, dynamic>)).toList(),
        ketQuas: (json['ketQuas'] as List?)?.map((e) => KetQuaDanhGiaModel.fromJson(e as Map<String, dynamic>)).toList(),
        isKhongTonTaiHoacBanGocKhongSuDung: json['isKhongTonTaiHoacBanGocKhongSuDung'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id': vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id,
        'isSuDung': isSuDung,
        'isCopy': isCopy,
        'vptq_kpi_DanhMucPI_Id': vptq_kpi_DanhMucPI_Id,
        'vptq_kpi_DanhMucPIChiTiet_Id': vptq_kpi_DanhMucPIChiTiet_Id,
        'maSoPI': maSoPI,
        'thuTuMa': thuTuMa,
        'chiSoDanhGia': chiSoDanhGia,
        'chuKy': chuKy,
        'vptq_kpi_NhomPI_Id': vptq_kpi_NhomPI_Id,
        'maNhomPI': maNhomPI,
        'tenNhomPI': tenNhomPI,
        'isNoiDung': isNoiDung,
        'isTang': isTang,
        'isKetQuaThucHien': isKetQuaThucHien,
        'vptq_kpi_DanhMucPIChiTietPhienBan_Id': vptq_kpi_DanhMucPIChiTietPhienBan_Id,
        'phienBan': phienBan,
        'hasCon': hasCon,
        'chiSoDanhGiaChiTiet': chiSoDanhGiaChiTiet,
        'duLieuThamDinh': duLieuThamDinh,
        'nguoiThamDinh_Id': nguoiThamDinh_Id,
        'tenNguoiThamDinh': tenNguoiThamDinh,
        'maNguoiThamDinh': maNguoiThamDinh,
        'vptq_kpi_DonViTinh_Id': vptq_kpi_DonViTinh_Id,
        'maDonViTinh': maDonViTinh,
        'tenDonViTinh': tenDonViTinh,
        'mucTieuTrongYeus': mucTieuTrongYeus?.map((e) => e.toJson()).toList(),
        'chiTietCons': chiTietCons?.map((e) => e.toJson()).toList(),
        'chucDanhs': chucDanhs?.map((e) => e.toJson()).toList(),
        'ketQuas': ketQuas?.map((e) => e.toJson()).toList(),
        'isKhongTonTaiHoacBanGocKhongSuDung': isKhongTonTaiHoacBanGocKhongSuDung,
      };
}

class MucTieuTrongYeuModel {
  String? vptq_kpi_DanhMucPIChiTietPhienBanMucTieuTrongYeu_Id;
  String? vptq_kpi_DanhMucPIChiTietPhienBan_Id;
  String? vptq_kpi_MucTieuTrongYeu_Id;
  String? maMucTieu;
  String? tenMucTieu;

  MucTieuTrongYeuModel({
    this.vptq_kpi_DanhMucPIChiTietPhienBanMucTieuTrongYeu_Id,
    this.vptq_kpi_DanhMucPIChiTietPhienBan_Id,
    this.vptq_kpi_MucTieuTrongYeu_Id,
    this.maMucTieu,
    this.tenMucTieu,
  });

  factory MucTieuTrongYeuModel.fromJson(Map<String, dynamic> json) => MucTieuTrongYeuModel(
        vptq_kpi_DanhMucPIChiTietPhienBanMucTieuTrongYeu_Id: json['vptq_kpi_DanhMucPIChiTietPhienBanMucTieuTrongYeu_Id'] as String?,
        vptq_kpi_DanhMucPIChiTietPhienBan_Id: json['vptq_kpi_DanhMucPIChiTietPhienBan_Id'] as String?,
        vptq_kpi_MucTieuTrongYeu_Id: json['vptq_kpi_MucTieuTrongYeu_Id'] as String?,
        maMucTieu: json['maMucTieu'] as String?,
        tenMucTieu: json['tenMucTieu'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'vptq_kpi_DanhMucPIChiTietPhienBanMucTieuTrongYeu_Id': vptq_kpi_DanhMucPIChiTietPhienBanMucTieuTrongYeu_Id,
        'vptq_kpi_DanhMucPIChiTietPhienBan_Id': vptq_kpi_DanhMucPIChiTietPhienBan_Id,
        'vptq_kpi_MucTieuTrongYeu_Id': vptq_kpi_MucTieuTrongYeu_Id,
        'maMucTieu': maMucTieu,
        'tenMucTieu': tenMucTieu,
      };
}

class DanhMucPiChiTietConModel {
  // JSON hiện tại `chiTietCons` là null, nhưng vẫn tạo model sẵn để mở rộng
  // Thêm các field khi backend trả dữ liệu cho node con.
  DanhMucPiChiTietConModel();

  factory DanhMucPiChiTietConModel.fromJson(Map<String, dynamic> json) => DanhMucPiChiTietConModel();

  Map<String, dynamic> toJson() => {};
}

class ChucDanhApDungModel {
  bool? isCongTy;
  bool? isRD;
  bool? isBanPhongNghiepVu;
  String? vptq_kpi_DanhMucPIChiTietPhienBanChucDanh_Id;
  String? chucDanh_Id;
  String? tenChucDanh;
  String? vptq_kpi_DanhMucPIChiTietPhienBan_Id;
  int? thuTu;

  ChucDanhApDungModel({
    this.isCongTy,
    this.isRD,
    this.isBanPhongNghiepVu,
    this.vptq_kpi_DanhMucPIChiTietPhienBanChucDanh_Id,
    this.chucDanh_Id,
    this.tenChucDanh,
    this.vptq_kpi_DanhMucPIChiTietPhienBan_Id,
    this.thuTu,
  });

  factory ChucDanhApDungModel.fromJson(Map<String, dynamic> json) => ChucDanhApDungModel(
        isCongTy: json['isCongTy'] as bool?,
        isRD: json['isRD'] as bool?,
        isBanPhongNghiepVu: json['isBanPhongNghiepVu'] as bool?,
        vptq_kpi_DanhMucPIChiTietPhienBanChucDanh_Id: json['vptq_kpi_DanhMucPIChiTietPhienBanChucDanh_Id'] as String?,
        chucDanh_Id: json['chucDanh_Id'] as String?,
        tenChucDanh: json['tenChucDanh'] as String?,
        vptq_kpi_DanhMucPIChiTietPhienBan_Id: json['vptq_kpi_DanhMucPIChiTietPhienBan_Id'] as String?,
        thuTu: json['thuTu'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'isCongTy': isCongTy,
        'isRD': isRD,
        'isBanPhongNghiepVu': isBanPhongNghiepVu,
        'vptq_kpi_DanhMucPIChiTietPhienBanChucDanh_Id': vptq_kpi_DanhMucPIChiTietPhienBanChucDanh_Id,
        'chucDanh_Id': chucDanh_Id,
        'tenChucDanh': tenChucDanh,
        'vptq_kpi_DanhMucPIChiTietPhienBan_Id': vptq_kpi_DanhMucPIChiTietPhienBan_Id,
        'thuTu': thuTu,
      };
}

class KetQuaDanhGiaModel {
  double? nhoHon; // nullable
  double? lonHonHoacBang; // nullable
  String? noiDung;
  String? vptq_kpi_KetQuaDanhGia_Id;
  String? tenKetQuaDanhGia;
  int? diem;
  bool? isApDung;

  KetQuaDanhGiaModel({
    this.nhoHon,
    this.lonHonHoacBang,
    this.noiDung,
    this.vptq_kpi_KetQuaDanhGia_Id,
    this.tenKetQuaDanhGia,
    this.diem,
    this.isApDung,
  });

  factory KetQuaDanhGiaModel.fromJson(Map<String, dynamic> json) => KetQuaDanhGiaModel(
        nhoHon: (json['nhoHon'] as num?)?.toDouble(),
        lonHonHoacBang: (json['lonHonHoacBang'] as num?)?.toDouble(),
        noiDung: json['noiDung'] as String?,
        vptq_kpi_KetQuaDanhGia_Id: json['vptq_kpi_KetQuaDanhGia_Id'] as String?,
        tenKetQuaDanhGia: json['tenKetQuaDanhGia'] as String?,
        diem: json['diem'] as int?,
        isApDung: json['isApDung'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'nhoHon': nhoHon,
        'lonHonHoacBang': lonHonHoacBang,
        'noiDung': noiDung,
        'vptq_kpi_KetQuaDanhGia_Id': vptq_kpi_KetQuaDanhGia_Id,
        'tenKetQuaDanhGia': tenKetQuaDanhGia,
        'diem': diem,
        'isApDung': isApDung,
      };
}

class NguoiDuyetPiModel {
  String? id;
  int? viTriDuyet;
  bool? isDuyet;
  String? tenCauHinhDuyetPI;
  String? nguoiDuyet_Id;
  String? tenNguoiDuyet;
  String? maNguoiDuyet;
  String? vptq_kpi_DanhMucPI_Id;
  String? thoiGianDuyet;

  NguoiDuyetPiModel({
    this.id,
    this.viTriDuyet,
    this.isDuyet,
    this.tenCauHinhDuyetPI,
    this.nguoiDuyet_Id,
    this.tenNguoiDuyet,
    this.maNguoiDuyet,
    this.vptq_kpi_DanhMucPI_Id,
    this.thoiGianDuyet,
  });

  factory NguoiDuyetPiModel.fromJson(Map<String, dynamic> json) => NguoiDuyetPiModel(
        id: json['id'] as String?,
        viTriDuyet: json['viTriDuyet'] as int?,
        isDuyet: json['isDuyet'] as bool?,
        tenCauHinhDuyetPI: json['tenCauHinhDuyetPI'] as String?,
        nguoiDuyet_Id: json['nguoiDuyet_Id'] as String?,
        tenNguoiDuyet: json['tenNguoiDuyet'] as String?,
        maNguoiDuyet: json['maNguoiDuyet'] as String?,
        vptq_kpi_DanhMucPI_Id: json['vptq_kpi_DanhMucPI_Id'] as String?,
        thoiGianDuyet: json['thoiGianDuyet'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'viTriDuyet': viTriDuyet,
        'isDuyet': isDuyet,
        'tenCauHinhDuyetPI': tenCauHinhDuyetPI,
        'nguoiDuyet_Id': nguoiDuyet_Id,
        'tenNguoiDuyet': tenNguoiDuyet,
        'maNguoiDuyet': maNguoiDuyet,
        'vptq_kpi_DanhMucPI_Id': vptq_kpi_DanhMucPI_Id,
        'thoiGianDuyet': thoiGianDuyet,
      };
}
