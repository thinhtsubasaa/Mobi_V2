class RoleModel {
  String? id;
  String? tenMenu;
  String? url;
  // List<MenuRoleModel>? children;

  RoleModel({
    this.id,
    this.tenMenu,
    this.url,
    // this.children,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json["id"].toString(),
      tenMenu: json["tenMenu"],
      url: json["url"],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'tenMenu': tenMenu,
        'url': url,
      };
}
