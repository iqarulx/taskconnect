/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '/services/http/http_config.dart';
import '/view/utils/snackbar.dart';

class FilePickerService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/file_upload.php");
    return url;
  }

  File? selectedFile;

  Future<File?> pickFile(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      selectedFile = File(result.files.single.path!);
      return selectedFile;
    } else {
      showSnackBar(context, content: 'File Not Uploaded', isSuccess: false);
      return null;
    }
  }

  Future<List<File>?> pickFiles(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      return files;
    } else {
      showSnackBar(context, content: 'Files Not Uploaded', isSuccess: false);
      return null;
    }
  }

  Future<String> uploadFile(File? file, String type, int index) async {
    if (file != null) {
      try {
        String fileName;
        if (type == 'recepient') {
          fileName = 'recipient_attachment';
        } else {
          fileName = 'attachment';
        }

        var url = await getDomain();
        var request = http.MultipartRequest('POST', url);

        DateTime now = DateTime.now();
        String timestamp =
            "${now.day}_${now.month}_${now.year}_${now.hour}_${now.minute}_${now.second}_$index";

        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: "${fileName}_$timestamp.${file.path.split('.').last}",
        ));

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var jsonResponse = json.decode(responseBody);
          return jsonResponse['head']['msg'].toString();
        } else {
          return 'Failed to upload file. Status code: ${response.statusCode}';
        }
      } catch (e) {
        rethrow;
      }
    } else {
      return '';
    }
  }
}
