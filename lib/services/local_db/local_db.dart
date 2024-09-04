/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:shared_preferences/shared_preferences.dart';

class LocalDBConfig {
  Future<SharedPreferences> connectLocalDb() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> checkLogin() async {
    var connection = await connectLocalDb();
    bool? result = connection.getBool('login');
    if (result == null) {
      return false;
    } else {
      return result;
    }
  }

  Future newUserLogin({
    required String userId,
    required String name,
    required String email,
  }) async {
    var connection = await connectLocalDb();
    connection.setString('user_id', userId);
    connection.setString('name', name);
    connection.setString('email', email);
    connection.setBool('login', true);
  }

  Future<String?> getUserId() async {
    var connection = await connectLocalDb();
    return connection.getString('user_id');
  }

  Future<String?> getName() async {
    var connection = await connectLocalDb();
    return connection.getString('name');
  }

  Future<String?> getEmail() async {
    var connection = await connectLocalDb();
    return connection.getString('email');
  }

  Future<bool> clearDB() async {
    var connection = await connectLocalDb();
    return connection.clear();
  }
}
