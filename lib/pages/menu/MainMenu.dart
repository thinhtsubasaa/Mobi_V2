import 'package:flutter/material.dart';
import 'package:Thilogi/pages/menu/custom_body_mainmenu.dart';
import 'package:Thilogi/config/config.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/user_bloc.dart';

class MainMenuPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 100.w,
                  child: Column(
                    children: [
                      // CustomCard(),
                      CustomBodyMainMenu(),
                      const SizedBox(height: 20),
                      Container(
                        color: Colors.white,
                        child: const Column(
                          children: [
                            CustomTitle(
                              text:
                                  'HỆ THỐNG QUẢN LÝ NGUỒN LỰC DOANH NGHIỆP (ERP)',
                            ),
                            SizedBox(height: 10),
                            Custombottom(
                              text:
                                  "Hệ thống bao gồm nhiều chức năng quản trị nghiệp vụ/ Dịch vụ của các Tổng công ty/ Công ty/ Đơn vị trực thuộc THILOGI",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomTitle extends StatelessWidget {
  final String text;

  const CustomTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 216, 30, 16),
          fontFamily: 'Roboto',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          height: 1.17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Key? key;

  const CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        AppConfig.appBarImagePath,
        width: 300,
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomCard extends StatefulWidget {
  const CustomCard({super.key});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late UserBloc _ub;
  String _fullName = "No name";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController!.addListener(_handleTabChange);
    _ub = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      _fullName = _ub.name!;
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
      height: 8.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFBC2925),
            Color(0xFFE96327),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(right: 5.w),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 5.w),
            child: Text(
              _fullName ?? "No name",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Comfortaa',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                height: 1.17,
                letterSpacing: 0,
              ),
            ),
          ),
          Container(
            child: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Custombottom extends StatelessWidget {
  final String text;

  const Custombottom({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF000000),
          fontFamily: 'Roboto',
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
