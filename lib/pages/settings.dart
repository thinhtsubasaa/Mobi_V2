import 'dart:io';
import 'dart:ui';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/utils/update_checker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:install_plugin_v2/install_plugin_v2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../blocs/theme_bloc.dart';
import '../utils/sign_out.dart';
import '../utils/snackbar.dart';
import '../widgets/divider.dart';

// ignore: must_be_immutable
class SettingPage extends StatefulWidget {
  Function? disposeHome;
  bool? notAllowCauHinhTram = false;
  SettingPage({super.key, this.disposeHome, this.notAllowCauHinhTram});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AppBloc _ab;
  String? _version;
  Map<String, dynamic>? values;

  @override
  void initState() {
    super.initState();
    // listen for download progress
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
    _ab = Provider.of<AppBloc>(context, listen: false);
    checkUpdate(_ab.appVersion);
  }

  checkUpdate(version) async {
    var checkVersion = UpdateChecker(
      context: context,
      baseApiUrl: _ab.apiUrl,
      currentVersion: version,
    );
    if (version == null) {
    } else {
      var tmpVal = await checkVersion.checkForUpdate();
      if (tmpVal == null) {
      } else {
        setState(() {
          _version = tmpVal["maPhienBan"];
          values = tmpVal;
          // callUpdateAction(tmpVal);
        });
      }
    }
  }

  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status.value, progress]);
  }

  // callUpdateAction(values) async {
  //   if ((values["maPhienBan"] != _ab.appVersion) &&
  //       values["isCapNhat"] == true) {
  //     // show a dialog to ask the user to download the update
  //     // ignore: use_build_context_synchronously
  //     bool shouldUpdate = await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text("Cập nhật"),
  //           content: const Text(
  //             "Ứng dụng đã có phiên bản mới. Bạn có muốn tải về không?",
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context, false),
  //               child: const Text("Huỷ"),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(context, true),
  //               child: const Text("Tải về và cài đặt"),
  //             ),
  //           ],
  //         );
  //       },
  //     );

  //     if (shouldUpdate) {
  //       await createDownloadDirectory();
  //       Directory? downloadsDirectory = await getExternalStorageDirectory();
  //       List<String> tmpArr = values["fileUrl"].split('/');
  //       // Get the file path
  //       final String filePath =
  //           '${downloadsDirectory!.path}/Download/${tmpArr.last}';

  //       // Check if the file exists
  //       final bool fileExists = File(filePath).existsSync();

  //       // Delete the file if it exists
  //       if (fileExists) {
  //         File(filePath).deleteSync();
  //       }

  //       String? downloadId = await FlutterDownloader.enqueue(
  //         url: '${_ab.apiUrl}/${values["fileUrl"]}',
  //         savedDir: '${downloadsDirectory.path}/Download',
  //         showNotification: true,
  //         openFileFromNotification: true,
  //         fileName: values["fileName"],
  //       );

  //       // wait for the download to complete
  //       bool isComplete = false;
  //       while (!isComplete) {
  //         List<DownloadTask>? tasks = await FlutterDownloader.loadTasks();
  //         DownloadTask? task =
  //             tasks?.firstWhere((task) => task.taskId == downloadId);

  //         if (task?.status == DownloadTaskStatus.complete) {
  //           isComplete = true;
  //           // Install the update using install_plugin_v2
  //           await InstallPlugin.installApk(
  //             '${downloadsDirectory.path}/Download/${tmpArr.last}',
  //             'com.thilogi.vn.logistics',
  //           ).then((value) {
  //             if (value == 'Success') {
  //               openSnackBar(context, "Tải xuống thành công");
  //             }
  //           });
  //         }
  //       }
  //     }
  //   }
  // }

  createDownloadDirectory() async {
    // Get the directory where the downloaded files should be saved
    Directory? downloadsDirectory = await getExternalStorageDirectory();
    // Create a new directory called "downloads" within the downloadsDirectory
    String downloadsPath = "${downloadsDirectory!.path}/Download";
    Directory downloadsDir = Directory(downloadsPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt').tr(),
      ),
      body: SingleChildScrollView(
        // physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 20,
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: UserUI(
              version: _version,
              values: values,
              // updateAction: callUpdateAction,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.onPrimary,
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       const Text(
          //         'general settings',
          //         style: TextStyle(
          //           fontSize: 15,
          //           fontWeight: FontWeight.w700,
          //           letterSpacing: -0.7,
          //           wordSpacing: 1,
          //         ),
          //       ).tr(),
          //       const SizedBox(height: 15),
          //       if (widget.notAllowCauHinhTram == false ||
          //           widget.notAllowCauHinhTram == null)
          //         ListTile(
          //           contentPadding: const EdgeInsets.all(0),
          //           leading: const CircleAvatar(
          //             backgroundColor: Colors.green,
          //             radius: 18,
          //             child: Icon(
          //               Icons.factory_outlined,
          //               size: 18,
          //               color: Colors.white,
          //             ),
          //           ),
          //           title: Text(
          //             'app configuration',
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w500,
          //               color: Theme.of(context).colorScheme.primary,
          //             ),
          //           ).tr(),
          //           trailing: const Icon(Feather.chevron_right),
          //           onTap: () => nextScreenPopup(
          //             context,
          //             AppSettings(
          //               disposeHome: widget.disposeHome!,
          //             ),
          //           ),
          //         ),
          //       const DividerWidget(),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Bản quyền thuộc về THACO THILOGI © 2024',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: -0.7,
                    wordSpacing: 1,
                  ),
                ).tr(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class UserUI extends StatelessWidget {
  final String? version;
  final Map<String, dynamic>? values;
  // final Function updateAction;
  const UserUI({
    super.key,
    required this.version,
    required this.values,
    // required this.updateAction,
  });

  @override
  Widget build(BuildContext context) {
    final UserBloc ub = context.watch<UserBloc>();
    final AppBloc ab = context.watch<AppBloc>();
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.greenAccent,
            radius: 18,
            child: Icon(
              Feather.cloud,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            ab.apiUrl,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const CircleAvatar(
            backgroundColor: Colors.black,
            radius: 18,
            child: Icon(
              Feather.activity,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text("Phiên bản ${ab.appVersion}"),
          // trailing: Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: const BoxDecoration(
          //     color: Colors.green,
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(10),
          //     ),
          //   ),
          //   child: Text(
          //     "$version",
          //     style: const TextStyle(color: Colors.white),
          //   ),
          // ),
          // onTap: () {
          //   // updateAction(values);
          // },
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 18,
            child: Icon(
              Feather.user_check,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            ub.name!.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.indigoAccent[100],
            radius: 18,
            child: const Icon(
              Feather.mail,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            ub.email!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.redAccent[100],
            radius: 18,
            child: const Icon(
              Feather.log_out,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          trailing: const Icon(Feather.chevron_right),
          onTap: () => openLogoutDialog(context),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 18,
            child: Icon(
              Icons.wb_sunny,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Chế độ tối',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          trailing: Switch(
              activeColor: Theme.of(context).primaryColor,
              value: context.watch<ThemeBloc>().darkTheme,
              onChanged: (_) {
                context.read<ThemeBloc>().toggleTheme();
              }),
        ),
      ],
    );
  }
}
