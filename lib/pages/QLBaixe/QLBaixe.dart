import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/QLBaixe/custom_body_QLBaixe.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

// ignore: use_key_in_widget_constructors
class QLBaiXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarQLKhoXe(key: Key('customAppBarQLKhoXe')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConfig
                            .backgroundImagePath), // Đường dẫn đến ảnh nền
                        fit: BoxFit.cover, // Cách ảnh nền sẽ được hiển thị
                      ),
                    ),
                    child: Column(
                      children: [
                        // CustomCardQLKhoXe(),
                        CustomBodyQLBaiXe(),
                        const SizedBox(height: 20),
                        Container(
                          child: const Column(
                            children: [
                              CustomTitle(
                                  text: 'QUẢN LÝ BÃI XE THÀNH PHẨM (WMS)'),
                              SizedBox(height: 10),
                              Custombottom(
                                  text:
                                      "Cung cấp ứng dụng quản lý vị trí xe trong bãi; tìm xe, xác nhận vận chuyển, giao xe thành phẩm."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 1.17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomAppBarQLKhoXe extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  final Key? key;

  const CustomAppBarQLKhoXe({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.QLKhoImagePath,
            width: 300,
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.only(left: 5.w),
              child: Text(
                'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFBC2925),
                  height: 16 / 14,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
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

class CustomCardQLKhoXe extends StatefulWidget {
  const CustomCardQLKhoXe({super.key});

  @override
  State<CustomCardQLKhoXe> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCardQLKhoXe>
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
            padding: EdgeInsets.only(left: 5.w),
            child: Text(
              'WMS',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                height: 28 / 24,
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 5.w),
                child: Icon(
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
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
