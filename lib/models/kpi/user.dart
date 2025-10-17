class UserKPIModel {
  final String? id;
  final String? fullName;
  final String? maNhanVien;
  final String? hinhAnhUrl;
  final String? email;
  final String? phoneNumber;

  final String? chucDanhId; // chucDanh_Id
  final String? tenChucDanh;
  final String? chucVuId; // chucVu_Id
  final String? tenChucVu;

  final String? donViId; // donVi_Id
  final String? tenDonVi;
  final String? maDonVi;

  final String? phongBanThacoId; // phongBanThaco_Id
  final String? maPhongBan;
  final String? tenPhongBan;

  final String? ngaySinh; // giữ String vì format dd/MM/yyyy
  final String? ngayVaoLam;

  final String? vptqKpiDonViKpiId; // vptq_kpi_DonViKPI_Id
  final String? tenDonViKPI;
  final String? maDonViKPI;

  const UserKPIModel({
    this.id,
    this.fullName,
    this.maNhanVien,
    this.hinhAnhUrl,
    this.email,
    this.phoneNumber,
    this.chucDanhId,
    this.tenChucDanh,
    this.chucVuId,
    this.tenChucVu,
    this.donViId,
    this.tenDonVi,
    this.maDonVi,
    this.phongBanThacoId,
    this.maPhongBan,
    this.tenPhongBan,
    this.ngaySinh,
    this.ngayVaoLam,
    this.vptqKpiDonViKpiId,
    this.tenDonViKPI,
    this.maDonViKPI,
  });

  factory UserKPIModel.fromJson(Map<String, dynamic> json) => UserKPIModel(
        id: json['id']?.toString(),
        fullName: json['fullName'],
        maNhanVien: json['maNhanVien'],
        hinhAnhUrl: json['hinhAnhUrl'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        chucDanhId: json['chucDanh_Id']?.toString(),
        tenChucDanh: json['tenChucDanh'],
        chucVuId: json['chucVu_Id']?.toString(),
        tenChucVu: json['tenChucVu'],
        donViId: json['donVi_Id']?.toString(),
        tenDonVi: json['tenDonVi'],
        maDonVi: json['maDonVi'],
        phongBanThacoId: json['phongBanThaco_Id']?.toString(),
        maPhongBan: json['maPhongBan'],
        tenPhongBan: json['tenPhongBan'],
        ngaySinh: json['ngaySinh'],
        ngayVaoLam: json['ngayVaoLam'],
        vptqKpiDonViKpiId: json['vptq_kpi_DonViKPI_Id']?.toString(),
        tenDonViKPI: json['tenDonViKPI'],
        maDonViKPI: json['maDonViKPI'],
      );
}
