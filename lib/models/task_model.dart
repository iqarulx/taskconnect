/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class TaskModel {
  String? entity,
      companyId,
      subject,
      description,
      department,
      priority,
      startDate,
      endDate;
  List<dynamic>? files, recepients, recepientAttachments;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["entity"] = entity;
    mapping["company_id"] = companyId;
    mapping["subject"] = subject;
    mapping["description"] = description;
    mapping["department"] = department;
    mapping["priority"] = priority;
    mapping["start_date"] = startDate;
    mapping["end_date"] = endDate;
    mapping["files"] = files;
    mapping["recepients"] = recepients;
    mapping["recepient_attachments"] = recepientAttachments;
    return mapping;
  }
}

class CompanyModel {
  String? companyName, companyId;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["company_name"] = companyName;
    mapping["company_id"] = companyId;
    return mapping;
  }
}

class DepartmentModel {
  String? departmentName, departmentId, companyId;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["department_name"] = departmentName;
    mapping["department_id"] = departmentId;
    mapping["company_id"] = companyId;
    return mapping;
  }
}

class UserModel {
  String? userId, userName;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = userName;
    mapping["user_id"] = userId;
    return mapping;
  }
}
