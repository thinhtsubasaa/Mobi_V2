import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificationqg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: NotificationScreen());
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // Yêu cầu quyền thông báo trên iOS
    _firebaseMessaging.requestPermission();

    // Lấy FCM Token
    _firebaseMessaging.getToken().then((String? token) {
      print("FCM Token: $token");
    }).catchError((e) {
      print("Error fetching FCM token: $e");
    });

    // Khởi tạo thông báo cục bộ
    initializeNotifications();

    // Lắng nghe thông báo khi ứng dụng ở nền hoặc mở ứng dụng
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận thông báo khi app đang mở: ${message.notification?.title}');
      showNotification(message); // Hiển thị thông báo cục bộ khi nhận được tin nhắn
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mở app từ thông báo: ${message.notification?.title}');
      // Xử lý sự kiện khi người dùng mở ứng dụng từ thông báo
    });
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onNotificationResponse);
    print("Initialized notifications with onNotificationResponse");
  }

  Future<void> onNotificationResponse(NotificationResponse response) async {
    print('Callback được gọi: onNotificationResponse');
    print('Action ID: ${response.actionId}');
    print('Payload: ${response.payload}');

    switch (response.actionId) {
      case 'ok':
        print("Người dùng chọn OK");
        _onOkPressed();
        break;
      case 'cancel':
        print("Người dùng chọn Cancel");
        _onCancelPressed();
        break;
      default:
        print("Action ID không hợp lệ hoặc không được gắn.");
    }
  }

  // Hàm sẽ được gọi khi người dùng nhấn "OK"
  void _onOkPressed() {
    print("Đã thực hiện hành động OK");
    // Thực hiện các hành động bạn cần ở đây
  }

  // Hàm sẽ được gọi khi người dùng nhấn "Cancel"
  void _onCancelPressed() {
    print("Đã thực hiện hành động Cancel");
    // Thực hiện các hành động bạn cần ở đây
  }

  void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'BMS',
      'Yều cầu thay đổi kế hoạch',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'ok', // Action ID
          'OK', // Nút OK
          // Cấu hình hành động nếu cần
        ),
        AndroidNotificationAction(
          'cancel', // Action ID
          'Cancel', // Nút Cancel
          // Cấu hình hành động nếu cần
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông báo Push")),
      body: Center(child: Text("Chờ nhận thông báo...")),
    );
  }
}
