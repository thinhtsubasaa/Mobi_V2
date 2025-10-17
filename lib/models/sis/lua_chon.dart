class LuaChonModel {
  final String id;
  final String noiDung;
  final bool? isCorrect;

  LuaChonModel({
    required this.id,
    required this.noiDung,
    required this.isCorrect,
  });

  factory LuaChonModel.fromJson(Map<String, dynamic> json) {
    return LuaChonModel(
      id: json["id"],
      noiDung: json["noiDung"],
      isCorrect: json["isCorrect"],
    );
  }
}