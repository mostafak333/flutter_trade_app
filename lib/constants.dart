import 'package:flutter/material.dart';

class Constants {
  static const double tableTitleFontSize = 18.0;
  static const double tableContentFontSize = 16.0;
  static const double padding = 10.0;

  static Color blue = Colors.blue;
  static Color red = Colors.red;
  static Color grey = Colors.grey;
  static Color tableHeaderColor = const Color(0xFF00499e);
  static Color white = Colors.white;
  static Color lightGreen = Colors.lightGreen;
  static Color lightBlue = const Color(0xFFBBDEFB);
  static Color green = Colors.green;

  static String resetPasswordEmailARContent(String newPassword) {
    return """
<!DOCTYPE html>
<html lang="ar">
<head>
  <meta charset="UTF-8">
  <title>إعادة تعيين كلمة المرور</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; color: #333;" dir="rtl">
  <div style="max-width: 600px; margin: auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0px 0px 8px rgba(0, 0, 0, 0.1); direction: rtl;">
    <div style="background-color: #EEC409; color: #452015; padding: 10px; text-align: center; border-radius: 8px 8px 0 0; font-size: 24px;">
      إعادة تعيين كلمة المرور
    </div>
    <div style="padding: 20px; line-height: 1.6; text-align: right; background-color: #F9F0C6; border-radius: 8px; margin-top: 10px;">
      <p style="color: #322513;">مرحبًا،</p>
      <p style="color: #322513;">تمت إعادة تعيين كلمة المرور الخاصة بك.<br>استخدم كلمة المرور التالية لتسجيل الدخول:</p>
      <p style="font-weight: bold; color: #E73A45; font-size: 18px;">$newPassword</p>
      <p style="color: #322513;">نوصي بتغيير كلمة المرور الخاصة بك بمجرد تسجيل الدخول.</p>
    </div>
    <div style="text-align: center; font-size: 12px; color: #666; margin-top: 20px; padding: 10px; border-top: 1px solid #E73A45;">
      <p>هذه رسالة آلية. يرجى عدم الرد على هذا البريد الإلكتروني.</p>
    </div>
  </div>
</body>
</html>
  """;
  }

  static String resetPasswordEmailENContent(String newPassword) {
    return """
    <!DOCTYPE html>
      <html>
      <head>
        <style>
          /* Style the entire email */
          body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
          }
          /* Container for main content */
          .container {
            max-width: 600px;
            margin: auto;
            background: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 0px 8px rgba(0, 0, 0, 0.1);
          }
          /* Header styling */
          .header {
            background-color: #007BFF;
            color: #ffffff;
            padding: 10px;
            text-align: center;
            border-radius: 8px 8px 0 0;
            font-size: 24px;
          }
          /* Content section styling */
          .content {
            padding: 20px;
            line-height: 1.6;
          }
          /* Password display styling */
          .password {
            font-weight: bold;
            color: #007BFF;
            font-size: 18px;
          }
          /* Footer with no-reply note */
          .footer {
            text-align: center;
            font-size: 12px;
            color: #666;
            margin-top: 20px;
            padding: 10px;
            border-top: 1px solid #e0e0e0;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">Password Reset</div>
          <div class="content">
            <p>Hello,</p>
            <p>Your password has been reset. Use the following password to log in:</p>
            <p class="password">$newPassword</p>
            <p>We recommend changing your password once you log in.</p>
          </div>
          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
          </div>
        </div>
      </body>
      </html>
  """;
  }
}
