class ChuKyModel {
  String? hinhAnhChuKySo;
  String? user_Id;

  ChuKyModel({
    this.hinhAnhChuKySo,
    this.user_Id,
  });
  factory ChuKyModel.fromJson(Map<String, dynamic> json) {
    return ChuKyModel(
      user_Id: json["user_Id"].toString(),
      hinhAnhChuKySo: json["hinhAnhChuKySo"],
    );
  }
  Map<String, dynamic> toJson() => {
        "hinhAnhChuKySo": hinhAnhChuKySo,
        "user_Id": user_Id,
      };
}
