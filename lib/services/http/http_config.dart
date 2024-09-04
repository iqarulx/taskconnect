/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class HttpConfig {
  Future<String?> getdomain() async {
    String result = "https://services.gulaidholding.com/task_connect_app/API";
    // String result =
    //     "http://sridemoapps.in/sridemoapps.in/arul2024/task_connect/API";
    return result;
  }

  Future<String?> getFiledomain() async {
    String result =
        "https://services.gulaidholding.com/task_connect_app/img/upload/";
    // "http://sridemoapps.in/sridemoapps.in/arul2024/task_connect/img/upload/";
    return result;
  }

  Future<Map<String, String>> getHeaders() async {
    Map<String, String> result = {
      'Access-Control-Allow-Origin': '*',
      'Authorization':
          'Bearer giDTpOjvOZCV9YHTyypVBzGUXhcFZQTrBlADIoFkwVvTF8pedMH7Lb8B7MjcSMSF',
      'Api-Key':
          'mZOs7oTx8yaa3QuEBvVXotO1U6rp4gyWSvG2xLK9cfzwfZjOrDu0Hu3WttgMMGr6',
      'Auth-Token':
          'oA0YOI1yjZQaercg35uDom1KvTFWKRR6rKqhtIa5ajHImxs6q3wrmJFhVMZSRlMd',
    };
    return result;
  }
}
