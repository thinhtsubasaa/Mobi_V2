class HangMucModel {
  String? id;
  String? noiDungBaoDuong;
  String? dinhMuc2;
  String? dinhMuc;
  String? loaiBaoDuong;
  String? ghiChu;
  String? chiPhi;
  String? tanSuat;
  String? bienSo1;
  String? bienSo2;
  String? ngay;
  String? soKM;
  String? tongChiPhi_TD;
  String? hangMuc_Id;
  String? phuongTien_Id;
  String? soKM_CanDenHan;
  String? giaTriBaoDuong;
  String? soKM_DaDiDuoc;
  bool? isBaoDuong;
  bool? isSuaChua;
  bool? isDenHan;
  bool? isDenHanSC;
  String? tieuChi;
  String? chiPhiBD2;
  String? chiPhiSC2;
  HangMucModel(
      {this.id,
      this.dinhMuc2,
      this.ghiChu,
      this.loaiBaoDuong,
      this.noiDungBaoDuong,
      this.tanSuat,
      this.bienSo1,
      this.bienSo2,
      this.ngay,
      this.chiPhi,
      this.dinhMuc,
      this.isSuaChua,
      this.tongChiPhi_TD,
      this.hangMuc_Id,
      this.soKM,
      this.isBaoDuong,
      this.phuongTien_Id,
      this.isDenHan,
      this.giaTriBaoDuong,
      this.soKM_DaDiDuoc,
      this.soKM_CanDenHan,
      this.isDenHanSC,
      this.chiPhiBD2,
      this.chiPhiSC2,
      this.tieuChi});
  factory HangMucModel.fromJson(Map<String, dynamic> json) {
    return HangMucModel(
        id: json["id"].toString(),
        noiDungBaoDuong: json["noiDungBaoDuong"],
        ghiChu: json["ghiChu"],
        dinhMuc2: json["dinhMuc2"],
        loaiBaoDuong: json["loaiBaoDuong"],
        tanSuat: json["tanSuat"],
        bienSo1: json["bienSo1"],
        bienSo2: json["bienSo2"],
        ngay: json["ngay"],
        chiPhi: json["chiPhi"],
        dinhMuc: json['dinhMuc'],
        hangMuc_Id: json["hangMuc_Id"],
        tongChiPhi_TD: json['tongChiPhi_TD'],
        isDenHan: json["isDenHan"],
        phuongTien_Id: json['phuongTien_Id'],
        isBaoDuong: json['isBaoDuong'],
        isSuaChua: json['isSuaChua'],
        soKM_CanDenHan: json['soKM_CanDenHan'],
        giaTriBaoDuong: json['giaTriBaoDuong'],
        soKM_DaDiDuoc: json['soKM_DaDiDuoc'],
        isDenHanSC: json['isDenHanSC'],
        tieuChi: json['tieuChi'],
        chiPhiBD2: json['chiPhiBD2'],
        chiPhiSC2: json['chiPhiSC2'],
        soKM: json['soKM']);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'noiDungBaoDuong': noiDungBaoDuong,
        'loaiBaoDuong': loaiBaoDuong,
        'tanSuat': tanSuat,
        'ghiChu': ghiChu,
        'hangMuc_Id': hangMuc_Id,
      };
}
