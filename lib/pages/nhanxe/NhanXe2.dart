import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:Thilogi/pages/nhanxe/popup/custom_popup_NhanXe.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sizer/sizer.dart';

class NhanXe2Page extends StatelessWidget {
  String? soKhung;
  String? soMay;
  String? tenMau;
  String? tenSanPham;
  String? ngayXuatKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? tenKho;
  List phuKien;

  NhanXe2Page(
      {required this.soKhung,
      required this.soMay,
      required this.tenMau,
      required this.tenSanPham,
      required this.ngayXuatKhoView,
      required this.tenTaiXe,
      required this.ghiChu,
      required this.tenKho,
      required this.phuKien});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarQLKhoXe(key: const Key('customAppBarQLKhoXe')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.8),
                        BlendMode.srcATop,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppConfig.backgroundImagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 5.0.h), // 5% of the screen's height
                      // CustomCardQLKhoXe(),
                      CustomCardVIN(),
                      SizedBox(height: 2.0.h),
                      CustomTitle(text: 'KIỂM TRA - NHẬN XE'),
                      SizedBox(height: 1.0.h),
                      Custombottom(
                        text:
                            "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI,",
                      ),
                    ],
                  ),

                  // Popup
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PopUp(
                      soKhung: soKhung ?? "",
                      soMay: soMay ?? "",
                      tenMau: tenMau ?? "",
                      tenSanPham: tenSanPham ?? "",
                      ngayXuatKhoView: ngayXuatKhoView ?? "",
                      tenTaiXe: tenTaiXe ?? "",
                      ghiChu: ghiChu ?? "",
                      tenKho: tenKho ?? "",
                      phuKien: phuKien ?? [],
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 216, 30, 16),
          fontFamily: 'Roboto',
          fontSize: 24.0.sp, // Responsive font size
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
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.QLKhoImagePath,
            width: 100.w,
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
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
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
      width: 334,
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
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
              fontSize: 16,
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
                height: 28 / 24,
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
