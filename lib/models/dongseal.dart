class DongSealModel {
  String? key;
  String? id;
  String? lat;
  String? long;
  String? soCont;
  String? soSeal;
  String? viTri;

  DongSealModel(
      {this.key,
      this.id,
      this.lat,
      this.long,
      this.soCont,
      this.soSeal,
      this.viTri});

  factory DongSealModel.fromJson(Map<String, dynamic> json) {
    return DongSealModel(
        key: json["key"],
        id: json["id"],
        soCont: json["soCont"],
        soSeal: json["soSeal"],
        lat: json["lat"],
        long: json["long"],
        viTri: json["viTri"]);
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "lat": lat,
        "long": long,
        "viTri": viTri,
      };
}
