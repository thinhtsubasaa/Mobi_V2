import 'package:flutter/material.dart';
import 'package:project/widgets/widget_body/custom_body_mainmenu.dart';
import 'package:project/config/config.dart';
import 'package:provider/provider.dart';

import '../blocs/user_bloc.dart';

// ignore: use_key_in_widget_constructors
class MainMenuPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // ignore: prefer_const_constructors
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: Column(
        children: [
          Expanded(
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Column(
                children: [
                  CustomCard(),
                  CustomBodyMainMenu(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: const Column(
                        children: [
                          CustomTitle(
                              text:
                                  'HỆ THỐNG QUẢN LÝ \n NGUỒN LỰC DOANH NGHIỆP\n(ERP)'),
                          SizedBox(height: 10),
                          Custombottom(
                              text:
                                  "Hệ thống bao gồm nhiều chức năng quản trị nghiệp vụ/ Dịch vụ của các Tổng công ty/ Công ty/ Đơn vị trực thuộc THILOGI"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTitle extends StatelessWidget {
  final String text;

  const CustomTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 216, 30, 16),
          fontFamily: 'Roboto',
          fontSize: 24,
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
  // ignore: overridden_fields
  final Key? key;

  // ignore: prefer_const_constructors_in_immutables
  CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        AppConfig.appBarImagePath,
        width: 300,
      ),
      centerTitle: false,
    );
  }

  @override
  // ignore: prefer_const_constructors
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
      width: 460,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFBC2925),
            Color(0xFFE96327),
          ],
        ),
        // Đặt border radius cho card
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              _fullName ?? "No name",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Comfortaa',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.17,
                letterSpacing: 0,
              ),
            ),
          ),
          // ignore: avoid_unnecessary_containers
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
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF000000),
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
