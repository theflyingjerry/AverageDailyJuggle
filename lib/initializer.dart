import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class JSONReader {
  String fileName = 'mySwingDataJSON';
  String stringJSON;
  Map<String, dynamic> jsonData = {};
  Map<String, dynamic> newClubData;
  Map<String, dynamic> initialClubDataMap = {'juggles': []};
  File filePath;
  bool fileExists;
  JSONReader({this.newClubData});

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/$fileName');
  }

  void writeJSON(Map jsonInput) async {
    filePath = await localFile;
    stringJSON = jsonEncode(jsonInput);
    filePath.writeAsString(stringJSON);
  }

  Future<Map> readJSON() async {
    filePath = await localFile;
    fileExists = await filePath.exists();
    if (fileExists == true) {
      try {
        stringJSON = await filePath.readAsString();
        jsonData = jsonDecode(stringJSON);
      } catch (e) {
        print('Issue reading file: $e');
      }
    } else {
      try {
        writeJSON(initialClubDataMap);
        stringJSON = await filePath.readAsString();
        jsonData = jsonDecode(stringJSON);
      } catch (e) {
        print('Issue reading file: $e');
      }
    }
    return jsonData;
  }
}
