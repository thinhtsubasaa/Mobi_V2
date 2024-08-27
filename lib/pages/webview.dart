import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Inject JavaScript to remove unwanted elements
            controller.runJavaScript("""
              document.querySelector('header').style.display = 'none';
              document.querySelector('footer').style.display = 'none';
              document.querySelector('.div_frame').scrollIntoView();
              """);
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://bms.thilogi.vn/danh-muc-kho-wms/so-do-kho'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is removed by not including it here
      resizeToAvoidBottomInset: false,
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}
