/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import '/models/task_model.dart';

Future<bool>? taskEditHandler;
List<TaskModel> taskDataList = [];
List<CompanyModel> companyDataList = [];
List<DepartmentModel> departmentDataList = [];
List<UserModel> userDataList = [];
List<UserModel> wholeUserDataList = [];
String? selectedCompanyId;
String? selectedCompany;
String? selectedDepartmentId;
String? selectedDepartment;
String selectedPriority = "1";
List<File> files = [];
List<String> selectedUserIds = [];
List<List<String>> selectedUsersRows = [];
List<String> uploadFiles = [];
List<dynamic> previousFiles = [];
List<dynamic> previousRecepients = [];
final TextEditingController subject = TextEditingController();
final TextEditingController description = TextEditingController();
TextEditingController startDate = TextEditingController();
TextEditingController endDate = TextEditingController();
final GlobalKey<FormState> formKey = GlobalKey<FormState>();
bool canEditForm = true;
