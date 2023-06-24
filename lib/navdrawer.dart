// ignore_for_file: library_private_types_in_public_api

import 'package:alfarsha/monthlyReport.dart';
import 'package:alfarsha/products.dart';
import 'package:alfarsha/listedDailyReport.dart';
import 'package:alfarsha/dailyReport.dart';
import 'package:flutter/material.dart';
import 'sqldb.dart';
import 'package:easy_localization/easy_localization.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  SqlDb sqlDb = SqlDb();
  List languageCode = ["en", "ar"];
  List countryCode = ["US", "SA"];

  void dropDB() async {
    await sqlDb.dropDataBase();
  }

  _displayLanguageDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Sale Row'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextButton(
                      child: const Text(
                        'English',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () {
                        EasyLocalization.of(context)?.setLocale(
                            Locale(languageCode[0], countryCode[0]));
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text(
                        'Arabic',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () {
                        EasyLocalization.of(context)?.setLocale(
                            Locale(languageCode[1], countryCode[1]));
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              "menu".tr().toString(),
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: Text("products".tr().toString()),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Products()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: Text("daily_report".tr().toString()),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DailyReport()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: Text("list_daily_report".tr().toString()),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ListedDailyReport()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: Text("monthly_report".tr().toString()),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MonthlyReport()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Drop DB'),
            onTap: () async {
              await sqlDb.dropDataBase();
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: Text("language".tr().toString()),
            onTap: () async {
              _displayLanguageDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
