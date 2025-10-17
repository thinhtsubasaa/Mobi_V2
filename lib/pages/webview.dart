import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController controller;
  late UserBloc? ub;

  @override
  void initState() {
    super.initState();
    ub = Provider.of<UserBloc>(context, listen: false);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // await _fillLoginForm();

            // Inject JavaScript to remove unwanted elements
            controller.runJavaScript("""
                document.querySelector('header').style.display = 'none';
                document.querySelector('footer').style.display = 'none';
                document.querySelector('.div_frame').scrollIntoView();
                """);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://bms.thilogi.vn/danh-muc-kho-wms/so-do-kho'));
  }

//   Future<void> _fillLoginForm() async {
//     if (ub?.maNhanVien != null) {
//       // Inject JavaScript to fill in the login form
//       await controller.runJavaScript("""
//   setTimeout(function() {
//     // Create a MutationObserver to monitor changes in the DOM
//     var observer = new MutationObserver(function(mutations) {
//       mutations.forEach(function(mutation) {
//         if (mutation.type === 'childList') {
//           document.getElementById('basic_username').value = '${ub?.maNhanVien}';
//           document.getElementById('basic_password').value = '${ub?.maNhanVien}';
//         }
//       });
//     });

//     // Observe changes in the form element
//     var targetNode = document.querySelector('form');
//     if (targetNode) {
//       observer.observe(targetNode, { childList: true, subtree: true });
//     }

//     // Set initial values
//     document.getElementById('basic_username').value = '${ub?.maNhanVien}';
//     document.getElementById('basic_password').value = '${ub?.maNhanVien}';

//     // Function to select the "Cá nhân" option from the dropdown
//     function selectOption() {
//       var selectElement = document.querySelector('.ant-select-selector');
//       if (selectElement) {
//         selectElement.click(); // Open the dropdown
//         setTimeout(function() {
//           var option = Array.from(document.querySelectorAll('.ant-select-item-option-content'))
//             .find(option => option.textContent === 'Cá nhân');
//           if (option) {
//             option.click(); // Select the option
//           }
//         }, 500); // Adjust the timeout as necessary
//       }
//     }

//     // Call the function to select the option
//     selectOption();
//   }, 1000); // Adjust the timeout as necessary
// """);
//     }
//   }

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

class NotifyItem {
  final String title, body;
  final DateTime time;
  bool unread;
  NotifyItem(this.title, this.body, this.time, {this.unread = true});
}

class NotifyDemo extends StatefulWidget {
  const NotifyDemo({super.key});
  @override
  State<NotifyDemo> createState() => _NotifyDemoState();
}

class _NotifyDemoState extends State<NotifyDemo> {
  final List<NotifyItem> _all = [
    NotifyItem('Bạn nhận được yêu cầu duyệt KPI đơn vị CÔNG TY KEO…', 'Bạn nhận được yêu cầu duyệt Đăng ký Chỉ tiêu KPI…', DateTime.now().subtract(const Duration(minutes: 5))),
    NotifyItem('Bạn nhận được yêu cầu đánh giá KPI PHÒNG HÀNH CHÍNH', 'Bạn nhận được yêu cầu đánh giá KPI…', DateTime.now().subtract(const Duration(days: 1, hours: 3)), unread: false),
    NotifyItem('Bạn nhận được yêu cầu duyệt PI CÔNG TY MÁY LẠNH…', 'Yêu cầu duyệt PI…', DateTime.now().subtract(const Duration(days: 3))),
  ];

  int get _unreadCount => _all.where((e) => e.unread).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openSheet,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none, size: 28),
                  if (_unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: const Center(child: Text('Nội dung khác')),
    );
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          String tab = 'Mới'; // Mới | Đã đọc | Tất cả
          List<NotifyItem> filtered() {
            if (tab == 'Mới') return _all.where((e) => e.unread).toList();
            if (tab == 'Đã đọc') return _all.where((e) => !e.unread).toList();
            return _all;
          }

          String dateLabel(DateTime d) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final dd = DateTime(d.year, d.month, d.day);
            if (dd == today) return 'Hôm nay';
            if (dd == today.subtract(const Duration(days: 1))) return 'Hôm qua';
            return '${dd.day.toString().padLeft(2, '0')}/${dd.month.toString().padLeft(2, '0')}/${dd.year}';
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.92,
            builder: (_, controller) => Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text('Thông báo (${_all.length})'),
                actions: [
                  TextButton(
                    onPressed: () {
                      for (final n in _all) n.unread = false;
                      setState(() {});
                      setLocal(() {});
                    },
                    child: const Text('Đánh dấu đã đọc'),
                  ),
                  TextButton(
                    onPressed: () {
                      _all.clear();
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Xóa tất cả'),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: ['Mới', 'Đã đọc', 'Tất cả'].map((t) {
                        final selected = t == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t),
                            selected: selected,
                            onSelected: (_) {
                              tab = t;
                              setLocal(() {});
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Builder(builder: (_) {
                      final items = filtered();
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('Không có thông báo'),
                        );
                      }
                      // nhóm theo ngày đơn giản
                      String? lastHeader;
                      return ListView.builder(
                        controller: controller,
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final n = items[i];
                          final label = dateLabel(n.time);
                          final header = (label != lastHeader)
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                                )
                              : const SizedBox.shrink();
                          lastHeader = label;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              header,
                              _NotifyTile(
                                n: n,
                                onTap: () {
                                  n.unread = false;
                                  setState(() {});
                                  setLocal(() {});
                                  // TODO: điều hướng chi tiết
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.mark_email_read_outlined),
                                            title: const Text('Đánh dấu đã đọc'),
                                            onTap: () {
                                              n.unread = false;
                                              setState(() {});
                                              Navigator.pop(context);
                                              setLocal(() {});
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete_outline),
                                            title: const Text('Xóa'),
                                            onTap: () {
                                              _all.remove(n);
                                              setState(() {});
                                              Navigator.pop(context);
                                              setLocal(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }),
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

class _NotifyTile extends StatelessWidget {
  final NotifyItem n;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _NotifyTile({required this.n, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final timeText = '${n.time.hour.toString().padLeft(2, '0')}:${n.time.minute.toString().padLeft(2, '0')} '
        '${n.time.day.toString().padLeft(2, '0')}/${n.time.month.toString().padLeft(2, '0')}/${n.time.year}';
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.unread ? const Color(0xFFF2F6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // chấm unread
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: n.unread ? Colors.blue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(n.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeText, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
