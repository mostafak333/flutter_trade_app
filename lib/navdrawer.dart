// ignore_for_file: library_private_types_in_public_api

import 'package:alfarsha/constants.dart';
import 'package:alfarsha/home.dart';
import 'package:alfarsha/inventory.dart';
import 'package:alfarsha/login.dart';
import 'package:alfarsha/monthlyReport.dart';
import 'package:alfarsha/products.dart';
import 'package:alfarsha/listedDailyReport.dart';
import 'package:alfarsha/dailyReport.dart';
import 'package:alfarsha/security.dart';
import 'package:alfarsha/settings.dart';
import 'package:flutter/material.dart';
import 'sqldb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  SqlDb sqlDb = SqlDb();
  List languageCode = ["en", "ar"];
  List countryCode = ["US", "SA"];
  Color IconBlue = Constants.tableHeaderColor;

  String? _projectName;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _projectName = prefs.getString('project_name');
      _imagePath = prefs.getString('image_path');
      print(">>>>>>>>>>>>> $_imagePath");
    });
  }

  void dropDB() async {
    await sqlDb.dropDataBase();
  }

  _displayLanguageDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Language'),
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

                        Navigator.of(context).pop(MaterialPageRoute(
                            builder: (context) => const Home()));
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
                        Navigator.of(context).pop(MaterialPageRoute(
                            builder: (context) => const Home()));
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
      child: Column(
        children: <Widget>[
          // Full width DrawerHeader
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _imagePath != null && File(_imagePath!).existsSync()
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: FileImage(File(_imagePath!)),
                      )
                    : const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _projectName ?? "menu".tr().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildListTile(
                  icon: Icons.shopping_cart,
                  text: "products".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Products()));
                  },
                ),
                _buildListTile(
                  icon: Icons.calendar_today,
                  text: "daily_report".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DailyReport()));
                  },
                ),
                _buildListTile(
                  icon: Icons.list_alt,
                  text: "list_daily_report".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ListedDailyReport()));
                  },
                ),
                _buildListTile(
                  icon: Icons.calendar_month,
                  text: "monthly_report".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MonthlyReport()));
                  },
                ),
                _buildListTile(
                  icon: Icons.inventory,
                  text: "inventory".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Inventory()));
                  },
                ),
                _buildListTile(
                  icon: Icons.settings,
                  text: "settings".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
                  },
                ),
                _buildListTile(
                  icon: Icons.lock,
                  text: "security".tr().toString(),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SecuritySettingsPage()));
                  },
                ),
                _buildListTile(
                  icon: Icons.language,
                  text: "language".tr().toString(),
                  onTap: () async {
                    _displayLanguageDialog(context);
                  },
                ),
                _buildListTile(
                  icon: Icons.logout,
                  text: "logout".tr().toString(),
                  textColor: Colors.red,
                  iconColor: Colors.red, // Set logout icon color to red
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool(
                        'isLoggedIn', false); // Clear login status
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    Color textColor = Colors.black,
    Color iconColor = Colors.blue, // Default icon color
    required void Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 18),
      ),
      onTap: onTap,
    );
  }
}
