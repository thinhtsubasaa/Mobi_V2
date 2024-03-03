import 'package:flutter/material.dart';
import 'package:project/blocs/user_bloc.dart';
import 'package:project/config/config.dart';
import 'package:project/widgets/widget_body/custom_body_QLKhoxe.dart';
import 'package:provider/provider.dart';

// ignore: use_key_in_widget_constructors
class QLKhoXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: CustomAppBarQLKhoXe(key: Key('customAppBarQLKhoXe')),
      body: Column(
        children: [
          Expanded(
            // ignore: avoid_unnecessary_containers
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      AppConfig.backgroundImagePath), // Đường dẫn đến ảnh nền
                  fit: BoxFit.cover, // Cách ảnh nền sẽ được hiển thị
                ),
              ),
              child: Column(
                children: [
                  CustomCardQLKhoXe(),
                  CustomBodyQLKhoXe(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: const Column(
                        children: [
                          CustomTitle(
                              text: 'QUẢN LÝ\n KHO XE THÀNH PHẨM\n (WMS)'),
                          SizedBox(height: 10),
                          Custombottom(
                              text:
                                  "Cung cấp ứng dụng quản lý vị trí xe trong bãi; tìm xe, xác nhận vận chuyển, giao xe thành phẩm."),
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

class CustomAppBarQLKhoXe extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  // ignore: overridden_fields
  final Key? key;

  // ignore: prefer_const_constructors_in_immutables
  CustomAppBarQLKhoXe({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.QLKhoImagePath,
            width: 300,
          ),
          // ignore: avoid_unnecessary_containers
          Container(
            child: const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Text(
                'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFBC2925), // Màu chữ
                  height: 16 / 14, // Tính line-height
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
  // ignore: prefer_const_constructors
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
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

// ignore: use_key_in_widget_constructors
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
      width: 460,
      height: 50,
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
        // Đặt border radius cho card
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Đặt giữa các thành phần
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: const Text(
              'WMS',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height:
                    28 / 24, // Tính line-height dựa trên fontSize và lineHeight
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          ),
          Row(
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
        ],
      ),
    );
  }
}
