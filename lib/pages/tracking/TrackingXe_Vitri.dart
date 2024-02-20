import 'package:flutter/material.dart';
import 'package:project/config/config.dart';
import 'package:project/widgets/widget_body/custom_body_tracking_vitri.dart';
import 'package:project/widgets/widget_tabs/custom_tabs_Tracking_Vitri.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// ignore: use_key_in_widget_constructors
class TrackingXeVitriPage extends StatelessWidget {
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
                  CustomCardVIN(),
                  SizedBox(height: 10),
                  CustomTabsTrackingVitri(),
                  SizedBox(height: 10),
                  CustomTrackingXeVitri(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: const Column(
                        children: [
                          CustomTitle(text: 'TRACKING XE THÀNH PHẨM'),
                          SizedBox(height: 10),
                          Custombottom(
                              text:
                                  "Tìm kiếm xe theo Đơn hàng/ Số VIN\n Theo dõi vị trí xe trong quá trình vận chuyển giao xe"),
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

class CustomCardVIN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        // Đặt border radius cho card
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180), // Màu của đường viền
          width: 1, // Độ dày của đường viền
        ),
        color: Colors.white, // Màu nền của card
      ),
      child: Row(
        children: [
          // Phần Text 1
          Container(
            width: 76.48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: Color(0xFFA71C20),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text trong cột
                Text(
                  'Số Khung\n(VIN)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.08, // Corresponds to line-height of 13px
                    letterSpacing: 0,

                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Phần Text 2
          const Text(
            'MALA851CBHM557809',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.11,
              letterSpacing: 0,
              color: Color(0xFFA71C20),
            ),
          ),
          const SizedBox(width: 3),
          // Phần Icon Barcode
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String barcodeScanResult =
                  await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              print(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }
}

class CustomCardQLKhoXe extends StatelessWidget {
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
                child: const Text(
                  'Account',
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
