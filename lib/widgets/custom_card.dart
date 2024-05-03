import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:Thilogi/pages/Account.dart';
import '../blocs/user_bloc.dart';
import '../pages/settings.dart';
import '../utils/sign_out.dart';
import 'package:Thilogi/utils/next_screen.dart';

enum MenuOption { Settings, Profile, Logout }

class CustomCard extends StatefulWidget {
  const CustomCard({super.key});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late UserBloc? _ub;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      _fullName = _ub?.name;
    });
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
                  // elevation: 50,
                  onSelected: (MenuOption result) {
                    switch (result) {
                      case MenuOption.Settings:
                        nextScreen(context, SettingPage());
                        break;
                      case MenuOption.Profile:
                        nextScreen(context, AccountPage());
                        break;
                      case MenuOption.Logout:
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
