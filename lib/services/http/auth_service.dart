/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class AuthService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/auth.php");
    return url;
  }

  getHeader() async {
    var headers = await super.getHeaders();
    return headers;
  }

  Future checkLogin(
      {required String username, required String password}) async {
    try {
      var url = await getDomain();
      var headers = await getHeader();
      var body = jsonEncode({"username": username, "password": password});
      var response = await http.post(url, headers: headers, body: body);
      var responseBody = json.decode(response.body);
      return responseBody;
    } catch (e) {
      rethrow;
    }
  }
}
