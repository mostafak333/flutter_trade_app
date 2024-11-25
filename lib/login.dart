import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SqlDb sqlDb = SqlDb();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Method to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _login() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_formKey.currentState?.validate() ?? false) {
      String projectName = _projectNameController.text;
      String password = _hashPassword(_passwordController.text);
      Map<String, dynamic>? project = await sqlDb.authenticateProject(projectName, password);

      if (project != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('project_name', project['name']);
        await prefs.setString('email', project['email']);
        await prefs.setInt('project_id', project['id']);
        await prefs.setString('image_path', project['image_path']);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('password', _hashPassword(_passwordController.text));

        navigator.pushReplacementNamed('/');
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'invalid_project_name_password'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to show language selection dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  EasyLocalization.of(context)
                      ?.setLocale(const Locale('en', 'US'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Arabic'),
                onTap: () {
                  EasyLocalization.of(context)
                      ?.setLocale(const Locale('ar', 'SA'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("login".tr().toString()),
          automaticallyImplyLeading: false, // Remove back arrow
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _showLanguageDialog,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _projectNameController,
                    decoration: InputDecoration(
                      labelText: "project_name".tr().toString(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_project_name'.tr().toString();
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "password".tr().toString(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_password'.tr().toString();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('login'.tr().toString()),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-project');
                    },
                    child: Text('create_project'.tr().toString()),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forget-password');
                    },
                    child: Text('forget_password'.tr().toString()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
