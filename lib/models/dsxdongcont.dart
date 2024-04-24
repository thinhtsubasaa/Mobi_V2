class DSX_DongContModel {
  String? key;
  String? id;
  String? lat;
  String? long;
  String? soCont;
  String? soSeal;
  String? viTri;
  String? dongCont;

  DSX_DongContModel(
      {this.key,
      this.id,
      this.lat,
      this.long,
      this.soCont,
      this.soSeal,
      this.dongCont,
      this.viTri});

  factory DSX_DongContModel.fromJson(Map<String, dynamic> json) {
    return DSX_DongContModel(
      key: json["key"],
      id: json["id"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      lat: json["lat"],
      long: json["long"],
      viTri: json["viTri"],
      dongCont: json["dongCont"],
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "lat": lat,
        "long": long,
        "viTri": viTri,
        "dongCont": dongCont,
      };
}
