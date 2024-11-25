import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:alfarsha/sqldb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'login.dart';
import 'constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  ForgetPasswordPageState createState() => ForgetPasswordPageState();
}

class ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final SqlDb sqlDb = SqlDb();

  // Function to generate a random password
  String _generateRandomPassword(int length) {
    const chars = '0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // Function to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Function to check internet connection
  Future<bool> _isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> sendPasswordResetEmail(
      String recipientEmail, String newPassword) async {
    String mailAddress = 'alfarsha00@gmail.com';
    String appPassword = 'ccxi byjk qcjy scnv';

    final smtpServer = gmail(mailAddress, appPassword);
    String currentLanguageCode = context.locale.languageCode;
    String emailBody = currentLanguageCode == 'ar'
        ? Constants.resetPasswordEmailARContent(newPassword)
        : Constants.resetPasswordEmailENContent(newPassword);
    final message = Message()
      ..from = Address(mailAddress, 'Al Farsha')
      ..recipients.add(recipientEmail)
      ..subject = 'Password Reset'
      ..html = emailBody;

    try {
      await send(message, smtpServer);
      return true;
    } on MailerException {
      return false;
    }
  }

  Future<void> _resetPassword() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Check for connection
    if (!await _isConnected()) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            "no_connection_message".tr().toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate form input
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Store email input
    String email = _emailController.text;

    // Check if email exists in the database
    var existingProject = await sqlDb.readData('''
    SELECT * FROM projects WHERE email = '$email'
  ''');

    if (existingProject.isEmpty) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "email_not_exists".tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Generate and hash a new password
    String newPassword = _generateRandomPassword(6);
    String hashedPassword = _hashPassword(newPassword);

    // Update the password in the database
    int response = await sqlDb.updateData('''
    UPDATE projects SET password = '$hashedPassword' WHERE email = '$email'
  ''');

    if (response <= 0) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "something_went_wrong".tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading dialog while sending email
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Send the reset email
    bool emailSent = await sendPasswordResetEmail(email, newPassword);

    // Dismiss the loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    // Handle email sending success or failure
    if (emailSent) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "password_reset_successful".tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the login page after a slight delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      }
    } else {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "error_sending_email".tr().toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
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
        title: Text("forget_password".tr().toString()),
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
                Center(
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text('send'.tr().toString()),
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
