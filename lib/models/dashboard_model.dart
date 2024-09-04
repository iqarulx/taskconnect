/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class DashboardCountModel {
  String? receivedCount,
      submittedCount,
      pendingCount,
      completedCount,
      rejectedCount,
      reminderCount,
      cancelledCount;
  bool? showInsights;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["received_count"] = receivedCount;
    mapping["submitted_count"] = submittedCount;
    mapping["pending_count"] = pendingCount;
    mapping["rejected_count"] = rejectedCount;
    mapping["reminder_count"] = reminderCount;
    mapping["cancelled_count"] = cancelledCount;
    mapping["completed_count"] = completedCount;
    mapping["show_insights"] = showInsights;
    return mapping;
  }
}

class ReallocateUserModel {
  String? employeeId, employeeName;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["employee_id"] = employeeId;
    mapping["employee_name"] = employeeName;
    return mapping;
  }
}
