class PheDuyetKPIModel {
  int? totalRow;
  int? totalPage;
  int? pageSize;
  DataList? datalist;

  PheDuyetKPIModel({
    this.totalRow,
    this.totalPage,
    this.pageSize,
    this.datalist,
  });

  factory PheDuyetKPIModel.fromJson(Map<String, dynamic> json) {
    return PheDuyetKPIModel(
      totalRow: json["totalRow"],
      totalPage: json["totalPage"],
      pageSize: json["pageSize"],
      datalist: json["datalist"] != null ? DataList.fromJson(json["datalist"]) : null,
    );
  }
  Map<String, dynamic> toJson() => {
        "totalRow": totalRow,
        "totalPage": totalPage,
        "pageSize": pageSize,
      };
}

class DataList {
  int? soLuong;
  int? soLuongHoanThanh;
  int? soLuongTraLai;
  int? soLuongChoBanDuyet;
  int? soLuongDangXuLy;
  List<PheDuyetItem>? data;

  DataList({
    this.soLuong,
    this.soLuongHoanThanh,
    this.soLuongTraLai,
    this.soLuongChoBanDuyet,
    this.soLuongDangXuLy,
    this.data,
  });

  factory DataList.fromJson(Map<String, dynamic> json) {
    return DataList(
      soLuong: json["soLuong"],
      soLuongHoanThanh: json["soLuongHoanThanh"],
      soLuongTraLai: json["soLuongTraLai"],
      soLuongChoBanDuyet: json["soLuongChoBanDuyet"],
      soLuongDangXuLy: json["soLuongDangXuLy"],
      data: json["data"] != null ? List<PheDuyetItem>.from(json["data"].map((x) => PheDuyetItem.fromJson(x))) : [],
    );
  }
}

class PheDuyetItem {
  String? id;
  String? nguoiDuyetHienTai_Id;
  int? loaiPhieuDuyet;
  String? tenLoaiPhieuDuyet;
  String? doiTuong;
  String? tenNguoiTao;
  String? tenDonViKPI;
  String? tenChucDanh;
  String? tenPhongBan;
  String? thoiDiem;
  String? ngayTao;
  int? viTriDuyet;
  String? createdDate;
  bool? isFirst;
  bool? isUyQuyen;
  bool? isCVKPI;
  bool? isThucHienDuyetKPICVDV;
  int? trangThai;
  bool? isTraKPICaNhanHoanThanh;
  bool? isDaXem;

  PheDuyetItem({
    this.id,
    this.nguoiDuyetHienTai_Id,
    this.loaiPhieuDuyet,
    this.tenLoaiPhieuDuyet,
    this.doiTuong,
    this.tenNguoiTao,
    this.tenDonViKPI,
    this.tenChucDanh,
    this.tenPhongBan,
    this.thoiDiem,
    this.ngayTao,
    this.viTriDuyet,
    this.createdDate,
    this.isFirst,
    this.isUyQuyen,
    this.isCVKPI,
    this.isThucHienDuyetKPICVDV,
    this.trangThai,
    this.isTraKPICaNhanHoanThanh,
    this.isDaXem,
  });

  factory PheDuyetItem.fromJson(Map<String, dynamic> json) {
    return PheDuyetItem(
      id: json["id"],
      nguoiDuyetHienTai_Id: json["nguoiDuyetHienTai_Id"],
      loaiPhieuDuyet: json["loaiPhieuDuyet"],
      tenLoaiPhieuDuyet: json["tenLoaiPhieuDuyet"],
      doiTuong: json["doiTuong"],
      tenNguoiTao: json["tenNguoiTao"],
      tenDonViKPI: json["tenDonViKPI"],
      tenChucDanh: json["tenChucDanh"],
      tenPhongBan: json["tenPhongBan"],
      thoiDiem: json["thoiDiem"],
      ngayTao: json["ngayTao"],
      viTriDuyet: json["viTriDuyet"],
      createdDate: json["createdDate"],
      isFirst: json["isFirst"],
      isUyQuyen: json["isUyQuyen"],
      isCVKPI: json["isCVKPI"],
      isThucHienDuyetKPICVDV: json["isThucHienDuyetKPICVDV"],
      trangThai: json["trangThai"],
      isTraKPICaNhanHoanThanh: json["isTraKPICaNhanHoanThanh"],
      isDaXem: json["isDaXem"],
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "nguoiDuyetHienTai_Id": nguoiDuyetHienTai_Id,
        "loaiPhieuDuyet": loaiPhieuDuyet,
        "tenLoaiPhieuDuyet": tenLoaiPhieuDuyet,
        "doiTuong": doiTuong,
        "tenNguoiTao": tenNguoiTao,
        "tenDonViKPI": tenDonViKPI,
        "tenChucDanh": tenChucDanh,
        "tenPhongBan": tenPhongBan,
        "thoiDiem": thoiDiem,
        "ngayTao": ngayTao,
        "viTriDuyet": viTriDuyet,
        "createdDate": createdDate,
        "isFirst": isFirst,
        "isUyQuyen": isUyQuyen,
        "isCVKPI": isCVKPI,
        "isThucHienDuyetKPICVDV": isThucHienDuyetKPICVDV,
        "trangThai": trangThai,
        "isTraKPICaNhanHoanThanh": isTraKPICaNhanHoanThanh,
        "isDaXem": isDaXem,
      };
}
