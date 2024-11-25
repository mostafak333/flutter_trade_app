import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:alfarsha/sqldb.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Unique identifier for the device
Future<String> getDeviceModel() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? "unknown_device"; // Get the unique ID for Android
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.model ?? "unknown_device"; // Get the unique ID for iOS
  }
  return "unknown_device";
}

// Upload database to Firebase
Future<void> uploadDatabaseToFirebase(String filePath, String deviceModel) async {
  // Create a reference to Firebase Storage
  FirebaseStorage storage = FirebaseStorage.instance;

  // Generate a timestamp in the format YYYYMMDDHHMM
  String timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '').replaceAll('-', '').substring(0, 12);

  // Create a reference using device-specific folder and timestamp
  String fileName = "alfarsha_$timestamp.db";
  Reference ref = storage.ref().child("$deviceModel/$fileName");

  // Upload the file
  File file = File(filePath);
  try {
    await ref.putFile(file);
    print('File uploaded successfully: $fileName');
  } catch (e) {
    print('Failed to upload file: $e');
  }
}

// Export and backup database
Future<void> backupDatabase() async {
  SqlDb sqlDb = SqlDb();
  String exportedFilePath = await sqlDb.exportDatabase();
  String deviceModel = await getDeviceModel();

  // Upload the exported file to Firebase Storage
  await uploadDatabaseToFirebase(exportedFilePath, deviceModel);
}

// Check connectivity and trigger backup
Future<void> checkAndBackup() async {
  ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult != ConnectivityResult.none) {
    // Internet is available, proceed with backup
    await backupDatabase();
  } else {
    print('No internet connection, will retry later.');
  }
}

// WorkManager background task
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await checkAndBackup();
    return Future.value(true); // Indicate the task was successful
  });
}