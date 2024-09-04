/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '/view/utils/colors.dart';

class TaskList {
  TaskList(
      this.sno,
      this.viewTask,
      this.subject,
      this.recipient,
      this.department,
      this.description,
      this.priority,
      this.startDate,
      this.endDate,
      this.kpiClock,
      this.start,
      this.completedExtend,
      this.reallocation,
      this.reject,
      this.nextStep);
  final String sno,
      subject,
      recipient,
      department,
      description,
      priority,
      startDate,
      endDate,
      kpiClock,
      nextStep;
  final Widget viewTask, completedExtend, start, reallocation, reject;
}

class TaskListDataSource extends DataGridSource {
  TaskListDataSource({
    required List<TaskList> taskListData,
    required int pageSize,
    required int initialPage,
  })  : allTaskListData = taskListData,
        _pageSize = pageSize,
        _currentPage = initialPage {
    _updatePage();
  }

  final List<TaskList> allTaskListData;
  final int _pageSize;
  int _currentPage;

  List<DataGridRow> _taskListData = [];

  _updatePage() {
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize < allTaskListData.length)
        ? startIndex + _pageSize
        : allTaskListData.length;

    _taskListData = allTaskListData
        .sublist(startIndex, endIndex)
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'sno', value: e.sno),
              DataGridCell<Widget>(columnName: 'viewTask', value: e.viewTask),
              DataGridCell<String>(columnName: 'subject', value: e.subject),
              DataGridCell<String>(columnName: 'recipient', value: e.recipient),
              DataGridCell<String>(
                  columnName: 'department', value: e.department),
              DataGridCell<String>(
                  columnName: 'description', value: e.description),
              DataGridCell<String>(columnName: 'priority', value: e.priority),
              DataGridCell<String>(columnName: 'startDate', value: e.startDate),
              DataGridCell<String>(columnName: 'endDate', value: e.endDate),
              DataGridCell<String>(columnName: 'kpiClock', value: e.kpiClock),
              DataGridCell<Widget>(columnName: 'start', value: e.start),
              DataGridCell<Widget>(
                  columnName: 'completedExtend', value: e.completedExtend),
              DataGridCell<Widget>(
                  columnName: 'reallocation', value: e.reallocation),
              DataGridCell<Widget>(columnName: 'reject', value: e.reject),
              DataGridCell<String>(columnName: 'nextStep', value: e.nextStep),
            ]))
        .toList();
  }

  void goToPage(int pageIndex) {
    _currentPage = pageIndex;
    _updatePage();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _taskListData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        if (e.columnName == 'completedExtend' ||
            e.columnName == 'start' ||
            e.columnName == 'reallocation' ||
            e.columnName == 'reject' ||
            e.columnName == 'viewTask') {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: e.value as Widget,
          );
        } else if (e.columnName == 'sno') {
          var data = e.value.split('/');
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  data[0].toString(),
                  style: const TextStyle(color: greenColor),
                ),
                if (data[1].toString() != '')
                  Text(
                    "Reminder : ${data[1].toString()}",
                    style: const TextStyle(color: redColor),
                  ),
              ],
            ),
          );
        } else {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }
      }).toList(),
    );
  }

  // Getter to expose total number of pages
  int get totalPages => (allTaskListData.length / _pageSize).ceil();
}
