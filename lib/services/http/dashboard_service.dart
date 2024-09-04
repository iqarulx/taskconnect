/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import '/services/local_db/local_db.dart';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class DashboardService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/dashboard.php");
    return url;
  }

  getHeader() async {
    var headers = await super.getHeaders();
    return headers;
  }

  Future getDashboardCount() async {
    var employeeId = await LocalDBConfig().getUserId();
    try {
      var url = await getDomain();
      var headers = await getHeader();
      var message = await http.post(url,
          headers: headers,
          body: jsonEncode({"dashboard_count": 1, "employee_id": employeeId}));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getTaskList(int? filter) async {
    var employeeId = await LocalDBConfig().getUserId();

    try {
      var url = await getDomain();
      var headers = await getHeader();
      if (filter != null) {
        var message = await http.post(url,
            headers: headers,
            body: jsonEncode({
              "task_list": 1,
              "employee_id": employeeId,
              "filter$filter": filter
            }));

        var response = json.decode(message.body);
        return response;
      } else {
        var message = await http.post(url,
            headers: headers,
            body: jsonEncode(
                {"task_list": 1, "employee_id": employeeId, "filter1": 1}));
        var response = json.decode(message.body);
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future startTask(String taskId) async {
    var employeeId = await LocalDBConfig().getUserId();

    try {
      var url = await getDomain();
      var headers = await getHeader();
      var message = await http.post(url,
          headers: headers,
          body: jsonEncode({
            "task_start": 1,
            "task_tracker_id": taskId,
            "employee_id": employeeId,
          }));

      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future completeTask(String taskId, String file) async {
    var employeeId = await LocalDBConfig().getUserId();
    try {
      var url = await getDomain();
      var headers = await getHeader();
      var message = await http.post(url,
          headers: headers,
          body: jsonEncode({
            "task_complete": 1,
            "task_tracker_id": taskId,
            "employee_id": employeeId,
            "attachment": file
          }));

      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getReallocateUser(String taskId) async {
    try {
      var url = await getDomain();
      var headers = await getHeader();
      var message = await http.post(url,
          headers: headers,
          body: jsonEncode({
            "task_reallocate": 1,
            "reallocate_users": 1,
            "task_tracker_id": taskId,
          }));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future reallocateTask(String taskId, String reallocateTo) async {
    var employeeId = await LocalDBConfig().getUserId();
    try {
      var url = await getDomain();
      var headers = await getHeader();
      var message = await http.post(url,
          headers: headers,
          body: jsonEncode({
            "task_reallocate": 1,
            "task_tracker_id": taskId,
            "employee_id": employeeId,
            "reallocate_to": reallocateTo,
          }));

      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future rejectTask(String taskId) async {
    var employeeId = await LocalDBConfig().getUserId();
    try {
      var url = await getDomain();
      var headers = await getHeader();
      var message = await http.post(url,
          headers: headers,
          body: jsonEncode({
            "reject_task": 1,
            "task_tracker_id": taskId,
            "employee_id": employeeId,
          }));

      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
