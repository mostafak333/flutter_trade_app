import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SqlDb sqlDb = SqlDb();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      String projectName = _projectNameController.text;
      String password = _passwordController.text;
      Map<String, dynamic>? project = await sqlDb.authenticateProject(projectName, password);

      if (project != null) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid project name or password')),
        );
      }
    }
  }

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
                title: Text('English'),
                onTap: () {
                  EasyLocalization.of(context)?.setLocale(Locale('en', 'US'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Arabic'),
                onTap: () {
                  EasyLocalization.of(context)?.setLocale(Locale('ar', 'SA'));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("login".tr().toString()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}