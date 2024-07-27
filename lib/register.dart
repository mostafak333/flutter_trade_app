import 'dart:io';

import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SqlDb sqlDb = SqlDb();
  String? _imagePath;

  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    int response = await sqlDb.insertData('''
      INSERT INTO projects (name, password, image_path) VALUES ('$username', '$password', '$_imagePath')
    ''');

    if (response > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'project_created_successfully'.tr().toString(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'fail_create_project'.tr().toString(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
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
        title: Text("create_project".tr().toString()),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'project_name'.tr().toString(),
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'password'.tr().toString(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: Text('upload_image'.tr().toString()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between button and image
                  if (_imagePath != null) ...[
                    Container(
                      height: 100.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_imagePath!),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  child: Text('create'.tr().toString()),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
