import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:Thilogi/models/lsu_giaoxe.dart';
import 'package:Thilogi/pages/dschoxacnhan/dsxacnhan.dart';
import 'package:Thilogi/pages/lichsuyeucaumoinhat/yeucaumoinhat.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:Thilogi/pages/nghiepvuchung/nghiepvuchung.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../blocs/menu_roles.dart';
import '../../config/config.dart';
import '../../models/menurole.dart';
import '../../widgets/loading.dart';
import 'package:new_version/new_version.dart';
import '../KPI_QuanLyKPI/KPI/KPI.dart';
import '../MMS_QuanLyPT_TB/mms_danhsachphuongtien/dsphuongtien.dart';
import '../MMS_QuanLyPT_TB/mms_quanlydanhsachphuongtien/qldsphuongtien.dart';
import '../MMS_QuanLyPT_TB/quanlyphuongtien_QLNew/quanlyphuongtien_canhan.dart';
import '../MMS_QuanLyPT_TB/quanlyphuongtien_QLNew/quanlyphuongtien_qlnew.dart';
import '../SIS_ThiTracNghiem/sis/sis.dart';
import '../dschogiaoxeho/dsxacnhangiaoxeho.dart';
import '../dschoxuatxeho/dsxacnhanxuatxeho.dart';
import '../lichsuyeucaumoinhatdigap/yeucaumoinhatdigap.dart';
import '../lichsuyeucaumoinhatgiaoho/yeucaumoinhatgiaoho.dart';
import '../MMS_QuanLyPT_TB/mms/Mms.dart';
import '../lichsuyeucaumoinhatxuatho/yeucaumoinhatxuatho.dart';
import '../thaydoixedigap/dsxacnhandigap.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyBms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyBmsScreen());
  }
}

class BodyBmsScreen extends StatefulWidget {
  const BodyBmsScreen({Key? key}) : super(key: key);

  @override
  _BodyBmsScreenState createState() => _BodyBmsScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyBmsScreenState extends State<BodyBmsScreen> with TickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0;
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  late MenuRoleBloc _mb;
  List<MenuRoleModel>? _menurole;
  List<MenuRoleModel>? get menurole => _menurole;

  static RequestHelper requestHelper = RequestHelper();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _message;
  String? get message => _message;
  LSX_GiaoXeModel? _data;

  String? url;
  late Future<List<MenuRoleModel>> _menuRoleFuture;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _checkVersion();
    _checkInternetAndShowAlert();
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    _menuRoleFuture = _fetchMenuRoles();
    _firebaseMessaging.requestPermission();

    // Lấy FCM Token
    _firebaseMessaging.getToken().then((String? token) {
      postData(token);
      print("FCM Token: $token");
    }).catchError((e) {
      print("Error fetching FCM token: $e");
    });
    initializeNotifications();
    if (Platform.isIOS) {
      foround();
    }

    // Lắng nghe thông báo khi ứng dụng ở nền hoặc mở ứng dụng
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận thông báo khi app đang mở: ${message.notification?.title}');
      // Hiển thị thông báo cục bộ khi nhận được tin nhắn
// showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mở app từ thông báo: ${message.notification?.title}');
      String? body = message.notification?.body?.toLowerCase();
      Map<String, dynamic> data = message.data;
      print("Data: $data");
      String? listIds;
      if (data.containsKey('listIds')) {
        try {
          listIds = data.containsKey('listIds') ? data['listIds'] : null;
        } catch (e) {
          print("Error decoding listIds: $e");
        }
      }
      print("body: $body");
      if (body != null) {
        if (body.contains('đang có') && !body.contains('giao xe hộ cần') && !body.contains("xuất xe hộ cần")) {
          nextScreen(context, DSXacNhanPage());
        } else if (body.contains('đã có') && !body.contains('yêu cầu bảo dưỡng') && !body.contains('yêu cầu sửa chữa') && !body.contains('lệnh hoàn thành')) {
          nextScreen(context, DSXacNhanDiGapPage());
        } else if (body.contains('xuất xe hộ cần')) {
          nextScreen(context, DSXacNhanXuatXeHoPage());
        } else if (body.contains('xuất xe hộ') && !body.contains('cần')) {
          nextScreen(context, LichSuYCMoiNhatXuatHoPage());
        } else if (body.contains('giao xe hộ cần')) {
          nextScreen(context, DSXacNhanGiaoXeHoPage());
        } else if (body.contains("giao xe hộ") && !body.contains('cần')) {
          nextScreen(context, LichSuYCMoiNhatGiaoHoPage());
        } else if (!body.contains('đang có') && !body.contains('đã có') && body.contains('trung chuyển đi gấp')) {
          // nextScreen(context, LichSuYCMoiNhatPage());
          nextScreen(context, LichSuYCMoiNhatDiGapPage());
        } else if (body.contains('nhập số km')) {
          // nextScreen(context, NhapKMPage());
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 0));
        } else if (body.contains('model') && !body.contains('hệ thống')) {
          // nextScreen(context, YeuCauBaoDuongPage(listIds: listIds));
          nextScreen(context, DanhSachPhuongTienPage());
        } else if (body.contains('hệ thống')) {
          // nextScreen(context, YeuCauBaoDuongPage(listIds: listIds));
          nextScreen(context, DanhSachPhuongTienQLPage());
        } else if (body.contains('yêu cầu bảo dưỡng') && !body.contains('vừa được xác nhận') && !body.contains('huỷ')) {
          nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 2));
        } else if (body.contains('lệnh hoàn thành bảo dưỡng phương tiện')) {
          nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 2));
        } else if (body.contains('vừa được xác nhận 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
        } else if (body.contains('vừa bị huỷ xác nhận 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
        } else if (body.contains('vừa bị huỷ 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
          nextScreen(context, DanhSachPhuongTienPage());
        } else if (body.contains('vừa được xác nhận 1 đề xuất hoàn thành bảo dưỡng phương tiện')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
        } else if (body.contains('vừa bị huỷ xác nhận 1 hoàn thành bảo dưỡng phương tiện') && !body.contains('đề xuất')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
        } else if (body.contains('yêu cầu sửa chữa') && !body.contains('vừa được xác nhận') && !body.contains('huỷ')) {
          nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 3));
        } else if (body.contains('lệnh hoàn thành sửa chữa phương tiện')) {
          nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 3));
        } else if (body.contains('vừa được xác nhận 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
        } else if (body.contains('vừa bị huỷ xác nhận 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
        } else if (body.contains('vừa bị huỷ 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
          nextScreen(context, DanhSachPhuongTienPage());
        } else if (body.contains('vừa được xác nhận 1 đề xuất hoàn thành sửa chữa phương tiện')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
        } else if (body.contains('vừa bị huỷ xác nhận 1 hoàn thành sửa chữa phương tiện') && !body.contains('đề xuất')) {
          nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
        } else {
          nextScreen(context, LichSuYCMoiNhatPage());
        }
      } else {
        // Trường hợp không có body trong thông báo
        print("Không có thông tin body trong thông báo.");
      }
      // Xử lý sự kiện khi người dùng mở ứng dụng từ thông báo
      //  if (message.notification?.body?.toLowerCase().contains('đang có') ?? false) {
      //       nextScreen(context, DSXacNhanPage());
      //     } else {
      //       nextScreen(context, LichSuYCMoiNhatPage());
      //     }
      // nextScreen(context, DSXacNhanPage());
    });
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Người dùng click vào thông báo khi ứng dụng được khởi động từ trạng thái tắt hoàn toàn: ${message.notification?.title}');
        String? body = message.notification?.body?.toLowerCase();
        Map<String, dynamic> data = message.data;
        print("Data: $data");
        String? listIds;
        if (data.containsKey('listIds')) {
          try {
            // listIds = List<String>.from(jsonDecode(data['listIds'])); // Decode JSON string
            listIds = data.containsKey('listIds') ? data['listIds'] : null;
          } catch (e) {
            print("Error decoding listIds: $e");
          }
        }
        if (body != null) {
          print("Body:$body");
          if (body.contains('đang có') && !body.contains('giao xe hộ cần') && !body.contains("xuất xe hộ cần")) {
            nextScreen(context, DSXacNhanPage());
          } else if (body.contains('đã có') && !body.contains('yêu cầu bảo dưỡng') && !body.contains('yêu cầu sửa chữa') && !body.contains('lệnh hoàn thành')) {
            nextScreen(context, DSXacNhanDiGapPage());
          } else if (body.contains('xuất xe hộ cần')) {
            nextScreen(context, DSXacNhanXuatXeHoPage());
          } else if (body.contains('xuất xe hộ') && !body.contains('cần')) {
            nextScreen(context, LichSuYCMoiNhatXuatHoPage());
          } else if (body.contains('giao xe hộ cần')) {
            nextScreen(context, DSXacNhanGiaoXeHoPage());
          } else if (body.contains("giao xe hộ") && !body.contains('cần')) {
            nextScreen(context, LichSuYCMoiNhatGiaoHoPage());
          } else if (!body.contains('đang có') && !body.contains('đã có') && body.contains('trung chuyển đi gấp')) {
            // nextScreen(context, LichSuYCMoiNhatPage());
            nextScreen(context, LichSuYCMoiNhatDiGapPage());
          } else if (body.contains('nhập số km')) {
            // nextScreen(context, NhapKMPage());
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 0));
          } else if (body.contains('model') && !body.contains('hệ thống')) {
            // nextScreen(context, YeuCauBaoDuongPage(listIds: listIds));
            nextScreen(context, DanhSachPhuongTienPage());
          } else if (body.contains('hệ thống')) {
            // nextScreen(context, YeuCauBaoDuongPage(listIds: listIds));
            nextScreen(context, DanhSachPhuongTienQLPage());
          } else if (body.contains('yêu cầu bảo dưỡng') && !body.contains('vừa được xác nhận') && !body.contains('huỷ')) {
            nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 2));
          } else if (body.contains('lệnh hoàn thành bảo dưỡng phương tiện')) {
            nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 2));
          } else if (body.contains('vừa được xác nhận 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
          } else if (body.contains('vừa bị huỷ xác nhận 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
          } else if (body.contains('vừa bị huỷ 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
            nextScreen(context, DanhSachPhuongTienPage());
          } else if (body.contains('vừa được xác nhận 1 đề xuất hoàn thành bảo dưỡng phương tiện')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
          } else if (body.contains('vừa bị huỷ xác nhận 1 hoàn thành bảo dưỡng phương tiện') && !body.contains('đề xuất')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
          } else if (body.contains('yêu cầu sửa chữa') && !body.contains('vừa được xác nhận') && !body.contains('huỷ')) {
            nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 3));
          } else if (body.contains('lệnh hoàn thành sửa chữa phương tiện')) {
            nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 3));
          } else if (body.contains('vừa được xác nhận 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
          } else if (body.contains('vừa bị huỷ xác nhận 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
          } else if (body.contains('vừa bị huỷ 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
            nextScreen(context, DanhSachPhuongTienPage());
          } else if (body.contains('vừa được xác nhận 1 đề xuất hoàn thành sửa chữa phương tiện')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
          } else if (body.contains('vừa bị huỷ xác nhận 1 hoàn thành sửa chữa phương tiện') && !body.contains('đề xuất')) {
            nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
          } else {
            nextScreen(context, LichSuYCMoiNhatPage());
          }
        } else {
          // Trường hợp không có body trong thông báo
          print("Không có thông tin body trong thông báo.");
        }
        //  if (message.notification?.body?.toLowerCase().contains('đang có') ?? false) {
        //     nextScreen(context, DSXacNhanPage());
        //   } else {
        //     nextScreen(context, LichSuYCMoiNhatPage());
        //   }
        // nextScreen(context, DSXacNhanPage());
      }
    });
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon'); // Tên biểu tượng đúng cho Android.

    // Cấu hình cho iOS mà không có 'onDidReceiveLocalNotification'
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );

    print("Initialized notifications for iOS and Android.");
  }

  Future<void> postData(String? token) async {
    try {
      final http.Response response = await requestHelper.postData('FireBase/FCMToken?token=$token', _data?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("Truyền token successfully");
        notifyListeners();
      } else {}
    } catch (e) {
      _message = e.toString();
      notifyListeners();
    }
  }

  Future<void> onNotificationResponse(NotificationResponse response) async {
    print('Callback được gọi: onNotificationResponse');
    String? body = response.payload?.toLowerCase();
    String? payload = response.payload; // Dữ liệu JSON được gửi từ thông báo
    String? listIds;
    if (payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(payload); // Parse JSON thành Map
        print("Data: $data");

        if (data.containsKey('listIds')) {
          listIds = data['listIds'];
          print("Datalisstid: $listIds");
        }
      } catch (e) {
        print("Error decoding payload: $e");
      }
    }
    if (body != null) {
      if (body.contains('đang có') && !body.contains('giao xe hộ cần') && !body.contains("xuất xe hộ cần")) {
        nextScreen(context, DSXacNhanPage());
      } else if (body.contains('đã có') && !body.contains('yêu cầu bảo dưỡng') && !body.contains('yêu cầu sửa chữa') && !body.contains('lệnh hoàn thành')) {
        nextScreen(context, DSXacNhanDiGapPage());
      } else if (body.contains('xuất xe hộ cần')) {
        nextScreen(context, DSXacNhanXuatXeHoPage());
      } else if (body.contains('xuất xe hộ') && !body.contains('cần')) {
        nextScreen(context, LichSuYCMoiNhatXuatHoPage());
      } else if (body.contains('giao xe hộ cần')) {
        nextScreen(context, DSXacNhanGiaoXeHoPage());
      } else if (body.contains("giao xe hộ") && !body.contains('cần')) {
        nextScreen(context, LichSuYCMoiNhatGiaoHoPage());
      } else if (!body.contains('đang có') && !body.contains('đã có') && body.contains('trung chuyển đi gấp')) {
        // nextScreen(context, LichSuYCMoiNhatPage());
        nextScreen(context, LichSuYCMoiNhatDiGapPage());
      } else if (body.contains('nhập số km')) {
        // nextScreen(context, NhapKMPage());
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 0));
      } else if (body.contains('model') && !body.contains('hệ thống')) {
        // nextScreen(context, YeuCauBaoDuongPage(listIds: listIds));
        nextScreen(context, DanhSachPhuongTienPage());
      } else if (body.contains('hệ thống')) {
        // nextScreen(context, YeuCauBaoDuongPage(listIds: listIds));
        nextScreen(context, DanhSachPhuongTienQLPage());
      } else if (body.contains('yêu cầu bảo dưỡng') && !body.contains('vừa được xác nhận') && !body.contains('huỷ')) {
        nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 2));
      } else if (body.contains('lệnh hoàn thành bảo dưỡng phương tiện')) {
        nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 2));
      } else if (body.contains('vừa được xác nhận 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
      } else if (body.contains('vừa bị huỷ xác nhận 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
      } else if (body.contains('vừa bị huỷ 1 yêu cầu bảo dưỡng phương tiện') && !body.contains('hoàn thành')) {
        nextScreen(context, DanhSachPhuongTienPage());
      } else if (body.contains('vừa được xác nhận 1 đề xuất hoàn thành bảo dưỡng phương tiện')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
      } else if (body.contains('vừa bị huỷ xác nhận 1 hoàn thành bảo dưỡng phương tiện') && !body.contains('đề xuất')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 3));
      } else if (body.contains('yêu cầu sửa chữa') && !body.contains('vừa được xác nhận') && !body.contains('huỷ')) {
        nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 3));
      } else if (body.contains('lệnh hoàn thành sửa chữa phương tiện')) {
        nextScreen(context, QuanLyPhuongTienQLNewPage(id: listIds, tabIndex: 3));
      } else if (body.contains('vừa được xác nhận 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
      } else if (body.contains('vừa bị huỷ xác nhận 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
      } else if (body.contains('vừa bị huỷ 1 yêu cầu sửa chữa phương tiện') && !body.contains('hoàn thành')) {
        nextScreen(context, DanhSachPhuongTienPage());
      } else if (body.contains('vừa được xác nhận 1 đề xuất hoàn thành sửa chữa phương tiện')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
      } else if (body.contains('vừa bị huỷ xác nhận 1 hoàn thành sửa chữa phương tiện') && !body.contains('đề xuất')) {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: listIds, tabIndex: 4));
      } else {
        nextScreen(context, LichSuYCMoiNhatPage());
      }
    } else {
      // Trường hợp không có body trong thông báo
      print("Không có thông tin body trong thông báo.");
    }
    // if (response.payload?.toLowerCase().contains('đang có') ?? false) {
    //   nextScreen(context, DSXacNhanPage());
    //     } else {
    //       nextScreen(context, LichSuYCMoiNhatPage());
    //     }
  }

  Future foround() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  Future showNotification(RemoteMessage message) async {
    print("Đã thực hiện hành động mo poup");

    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(
        // presentAlert: true, // Hiển thị thông báo dạng banner
        // presentBadge: true, // Hiển thị badge trên biểu tượng ứng dụng
        // presentSound: true, // Phát âm thanh thông báo
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iosPlatformChannelSpecifics,
    );
    int uniqueId = DateTime.now().second + Random().nextInt(1000);
    await flutterLocalNotificationsPlugin.show(
      //  uniqueId,
      0,
      message.notification?.title, // Tiêu đề thông báo
      message.notification?.body, // Nội dung thông báo
      platformChannelSpecifics,
      payload: message.notification?.body, // Dữ liệu đính kèm (nếu cần)
    );
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      iOSId: "",
      androidId: "",
    );
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      if (_isVersionLower(status.localVersion, status.storeVersion)) {
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: "CẬP NHẬT",
          dismissButtonText: "Bỏ qua",
          dialogText: "Ứng dụng đã có phiên bản mới, vui lòng cập nhật " + "${status.localVersion}" + " lên " + "${status.storeVersion}",
          dismissAction: () {
            SystemNavigator.pop();
          },
          allowDismissal: false,
          updateButtonText: "Cập nhật",
        );
      }
      print("DEVICE : " + status.localVersion);
      print("STORE : " + status.storeVersion);
    }
  }

  bool _isVersionLower(String localVersion, String storeVersion) {
    final localParts = localVersion.split('.').map(int.parse).toList();
    final storeParts = storeVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < localParts.length; i++) {
      if (localParts[i] < storeParts[i]) return true;
      if (localParts[i] > storeParts[i]) return false;
    }

    // If we get here, all parts are equal
    return false;
  }

  Future<List<MenuRoleModel>> _fetchMenuRoles() async {
    // Thực hiện lấy dữ liệu từ MenuRoleBloc
    await _mb.getData(context, DonVi_Id, PhanMem_Id);
    return _mb.menurole ?? [];
  }

  void _checkInternetAndShowAlert() {
    AppService().checkInternet().then((hasInternet) async {
      if (!hasInternet!) {
        // Reset the button state if necessary

        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      }
    });
  }

  bool userHasPermission(List<MenuRoleModel> menuRoles, String? url1) {
    // Kiểm tra xem menuRoles có chứa quyền truy cập đến url1 không
    return menuRoles.any((menuRole) => menuRole.url == url1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuRoleModel>>(
      future: _menuRoleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget(context);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          // Chuyển hướng sang trang đăng nhập nếu không có dữ liệu
          Future.microtask(() => _goToLoginPage());
          return Container();
        } else {
          // Dữ liệu đã được tải, xây dựng giao diện
          return _buildContent(snapshot.data!);
        }
      },
    );
  }

  void _goToLoginPage() {
    nextScreenReplace(context, LoginPage());
  }

  @override
  Widget _buildContent(List<MenuRoleModel> menuRoles) {
    return _loading
        ? LoadingWidget(context)
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              margin: const EdgeInsets.only(top: 25, bottom: 25),
              child: Wrap(
                spacing: 20.0, // khoảng cách giữa các nút
                runSpacing: 20.0, // khoảng cách giữa các hàng
                alignment: WrapAlignment.center,
                children: [
                  if (userHasPermission(menuRoles, 'quan-ly-kho-thanh-pham-mobi'))
                    CustomButton(
                      'THILOTRANS\nAUTO',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Main_button_THILOTrans.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(QLKhoXePage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'nghiep-vu-co-ban-mobi'))
                    CustomButton(
                      'NGHIỆP VỤ CƠ BẢN',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Main_button_01_QTNVChung.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(NghiepVuChungPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'mms-mobi'))
                    CustomButton(
                      'MMS',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/MMS_Logo.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(MmsPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'sis-mobi'))
                    CustomButton(
                      'SIS',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/SIS_Logo.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(SisPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'kpi-mobi'))
                    CustomButton(
                      'KPI',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/KPI_Logo_New.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(KPIPage());
                      },
                    ),
                ],
              ),
            ),
          );
  }

  void _handleButtonTap(Widget page) {
    setState(() {
      _loading = true;
    });
    nextScreen(context, page);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

Widget CustomButton(String buttonText, Widget page, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 35.w,
      // height: 35.h,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: page,
          ),
          Text(
            buttonText.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ),
    ),
  );
}
