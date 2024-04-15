import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/chuyenxe/custom_body_chuyenxe.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';
import '../blocs/user_bloc.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 100.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig.backgroundImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: CustomBodyAccount(),
              ),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class CustomBodyAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyAccountScreen());
  }
}

class BodyAccountScreen extends StatefulWidget {
  const BodyAccountScreen({Key? key}) : super(key: key);

  @override
  _BodyAccountScreenState createState() => _BodyAccountScreenState();
}

class _BodyAccountScreenState extends State<BodyAccountScreen>
    with SingleTickerProviderStateMixin {
  late UserBloc? _ub;

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        const SizedBox(height: 5),
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withOpacity(1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông Tin Cá Nhân',
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFA71C20)),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          SizedBox(height: 4),
                          MyInputWidget(
                            title: "Họ và tên",
                            text: _ub?.name ?? "",
                            textStyle: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.textInput,
                            ),
                          ),
                          SizedBox(height: 5),
                          MyInputWidget(
                            title: "Email",
                            text: _ub?.email ?? "",
                            textStyle: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.textInput,
                            ),
                          ),
                          SizedBox(height: 5),
                          MyInputWidget(
                            title: "Role ",
                            text: _ub?.accessRole ?? "",
                            textStyle: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.textInput,
                            ),
                          ),
                          SizedBox(height: 5),
                          MyInputWidget(
                            title: "Hình ảnh",
                            text: _ub?.hinhAnhUrl ?? "",
                            textStyle: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.textInput,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class MyInputWidget extends StatelessWidget {
  final String title;
  final String text;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF6C6C7),
              border: Border(
                right: BorderSide(
                  color: Color(0xFF818180),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppConfig.textInput,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(top: 5, left: 5.sp),
              child: Text(
                text,
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      child: Center(
        child: customTitle(
          'KIỂM TRA - THÔNG TIN CÁ NHÂN',
        ),
      ),
    );
  }
}
