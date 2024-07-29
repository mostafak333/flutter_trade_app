import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:alfarsha/sqldb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SqlDb sqlDb = SqlDb();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      String oldPassword = _hashPassword(_oldPasswordController.text);
      String newPassword = _newPasswordController.text.isEmpty
          ? oldPassword
          : _hashPassword(_newPasswordController.text);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('project_name') ?? '';

      // Validate old password
      Map<String, dynamic>? project =
      await sqlDb.authenticateProject(username, oldPassword);
      if (project == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invalid_old_password'.tr().toString()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update password
      int response = await sqlDb.updateData('''
        UPDATE projects SET password = '$newPassword' WHERE name = '$username'
      ''');

      if (response > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'password_updated_successfully'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'fail_update_password'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("security_settings".tr().toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'old_password'.tr().toString(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_old_password'.tr().toString();
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'new_password'.tr().toString(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updatePassword,
                  child: Text('update_password'.tr().toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
