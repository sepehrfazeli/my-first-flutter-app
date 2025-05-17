import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<void> saveUserDataToFile(Map<String, dynamic> userData) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/users.json';
    final file = File(filePath);

    List<dynamic> usersList = [];
    if (await file.exists()) {
      String existingContent = await file.readAsString();
      usersList = jsonDecode(existingContent);
    }

    usersList.add(userData);
    await file.writeAsString(jsonEncode(usersList));
    print('User data saved to $filePath');
  } catch (e) {
    print("Failed to save user data: $e");
  }
}
