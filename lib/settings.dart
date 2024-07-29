import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
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
    _usernameController.text = prefs.getString('project_name') ?? '';
    _imagePath = prefs.getString('image_path');
    setState(() {});
  }

  Future<void> _updateProjectSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = _usernameController.text;
    int projectId = prefs.getInt('project_id') ?? 0;

    // Update project data
    int response = await sqlDb.updateData('''
    UPDATE projects SET name = '$username', image_path = '$_imagePath' WHERE id = $projectId
  ''');

    if (response > 0) {
      await prefs.setString('project_name', username);
      await prefs.setString('image_path', _imagePath ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'info_updated_successfully'.tr().toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/'); // Navigate to home page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'fail_update_info'.tr().toString(),
            style: const TextStyle(color: Colors.white),
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
                  controller: _usernameController,
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
