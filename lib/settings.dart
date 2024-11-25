import 'dart:ffi';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final SqlDb sqlDb = SqlDb();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _projectNameController.text = prefs.getString('project_name') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
    _imagePath = prefs.getString('image_path');
    setState(() {});
  }

  Future<void> _updateProjectSettings() async {

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_formKey.currentState?.validate() ?? false) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String projectName = _projectNameController.text;
    String email = _emailController.text;
    int projectId = prefs.getInt('project_id') ?? 0;


    // Step 1: Check if the email already exists
    var existingEmail = await sqlDb.readData('''
      SELECT * FROM projects WHERE email = '$email' AND id != '$projectId'
    ''');

    var existingProjectName = await sqlDb.readData('''
      SELECT * FROM projects WHERE name = '$projectName' AND id != '$projectId'
    ''');
    if (existingProjectName.isNotEmpty) {
      // If the email already exists, show an error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'projectName_already_exists'.tr().toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (existingEmail.isNotEmpty) {
      // If the email already exists, show an error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'email_already_exists'.tr().toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Update project data
    int response = await sqlDb.updateData('''
    UPDATE projects SET name = '$projectName', image_path = '$_imagePath', email = '$email' WHERE id = $projectId
  ''');

    if (response > 0) {
      await prefs.setString('project_name', projectName);
      await prefs.setString('email', email);
      await prefs.setString('image_path', _imagePath ?? '');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'info_updated_successfully'.tr().toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pushReplacementNamed('/'); // Navigate to home page
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'fail_update_info'.tr().toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr().toString()),
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
                                  style: const TextStyle(color: Colors.black45)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProjectSettings,
                    child: Text('update'.tr().toString()),
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
