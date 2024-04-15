class MenuRoleModel {
  String? id;
  String? tenMenu;
  String? url;
  final List<MenuRoleModel> children;

  MenuRoleModel({
    this.id,
    this.tenMenu,
    this.url,
    required this.children,
  });
  @override
  String toString() {
    return 'MenuRoleModel(id: $id, tenMenu: $tenMenu, url: $url)';
  }

  factory MenuRoleModel.fromJson(Map<String, dynamic> json) {
    return MenuRoleModel(
        id: json["id"].toString(),
        tenMenu: json["tenMenu"],
        url: json["url"],
        children: (json["children"] as List)
            .map((item) => MenuRoleModel.fromJson(item))
            .toList());
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'tenMenu': tenMenu,
        'url': url,
      };
}
