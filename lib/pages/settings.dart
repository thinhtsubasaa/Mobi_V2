import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';


import '../utils/sign_out.dart';
import '../widgets/divider.dart';

class UserUI extends StatelessWidget {
  final String? version;
  final Map<String, dynamic>? values;
  final Function updateAction;
  const UserUI({
    super.key,
    required this.version,
    required this.values,
    required this.updateAction,
  });

  @override
  Widget build(BuildContext context) {
    final UserBloc ub = context.watch<UserBloc>();
    final AppBloc ab = context.watch<AppBloc>();
    return Column(
      children: [
        ListTile(
          contentPadding:  EdgeInsets.all(0),
          leading:  CircleAvatar(
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
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Text(
              "$version",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            updateAction(values);
          },
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
            'logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          trailing: const Icon(Feather.chevron_right),
          onTap: () => openLogoutDialog(context),
        ),
      ],
    );
  }
}