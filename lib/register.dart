import 'dart:convert';
import 'dart:io';
import 'package:alfarsha/login.dart';
import 'package:crypto/crypto.dart';
import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation
  final SqlDb sqlDb = SqlDb();
  String? _imagePath;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      String projectName = _projectNameController.text;
      String email = _emailController.text;
      String password = _hashPassword(_passwordController.text);

      // Step 1: Check if the email already exists
      var existingEmail = await sqlDb.readData('''
      SELECT * FROM projects WHERE email = '$email'
    ''');

      var existingProjectName = await sqlDb.readData('''
      SELECT * FROM projects WHERE name = '$projectName'
    ''');

      if (existingProjectName.isNotEmpty) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'project_name_already_exists'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (existingEmail.isNotEmpty) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'email_already_exists'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Step 2: Proceed with registration if the email does not exist
      int response = await sqlDb.insertData('''
      INSERT INTO projects (name, email, password, image_path) 
      VALUES ('$projectName', '$email', '$password', '$_imagePath')
    ''');

      if (response > 0) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'project_created_successfully'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'fail_create_project'.tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _projectNameController,
                  decoration: InputDecoration(
                    labelText: 'project_name'.tr().toString(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_project_name'.tr().toString();
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'email'.tr().toString(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_email'.tr().toString();
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'enter_valid_email'.tr().toString();
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password'.tr().toString(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.black45),
                              const SizedBox(height: 8),
                              Text('upload_image'.tr().toString(),
                                  style:
                                      const TextStyle(color: Colors.black45)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Space between button and image
                    if (_imagePath != null) ...[
                      SizedBox(
                        width: 100, // Adjust the width as needed
                        height: 100, // Adjust the height as needed
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8), // Rounded corners for the image
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover, // Adjust image fit
                          ),
                        ),
                      ),
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
      ),
    );
  }
}
