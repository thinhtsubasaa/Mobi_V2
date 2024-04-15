import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../blocs/user_bloc.dart';
import '../utils/sign_out.dart';

enum MenuOption { Settings, Profile, Logout }

class CustomCard extends StatefulWidget {
  const CustomCard({super.key});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late UserBloc? _ub;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController!.addListener(_handleTabChange);
    _ub = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      _fullName = _ub?.name;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      // Call the action when the tab changes
      // print('Tab changed to: ${_tabController!.index}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 7.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE96327),
            Color(0xFFBC2925),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(left: 3.w),
            child: Text(
              'WMS',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 2.w, bottom: 3),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              Container(
                child: Text(
                  _fullName ?? "No name",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Comfortaa',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                child: PopupMenuButton<MenuOption>(
                  onSelected: (MenuOption result) {
                    // Xử lý khi một mục được chọn
                    switch (result) {
                      case MenuOption.Settings:
                        // Xử lý khi chọn Cài đặt
                        break;
                      case MenuOption.Profile:
                        // Xử lý khi chọn Thông tin cá nhân
                        break;
                      case MenuOption.Logout:
                        // Xử lý khi chọn Logout
                        signOut(context);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: MenuOption.Settings,
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8.0),
                          Text('Cài đặt'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: MenuOption.Profile,
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8.0),
                          Text('Thông tin cá nhân'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: MenuOption.Logout,
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8.0),
                          Text('Đăng xuất'),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                  color: Colors.white, // Màu nền của menu
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
