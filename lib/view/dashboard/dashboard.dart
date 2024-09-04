/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '/models/dashboard_model.dart';
import '/services/http/dashboard_service.dart';
import '/services/local_db/local_db.dart';
import '/view/dashboard/pagination.dart';
import '/view/dashboard/task_list.dart';
import '/view/task/task_edit.dart';
import '/view/task/task_view.dart';
import '/view/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import 'helper.dart' as helper;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appbar(),
        body: body(),
        floatingActionButton: floatingButtons(),
        endDrawer: drawer(context, name, email, showInsights ?? false,
            currentVersion ?? '1.0.1'),
      ),
    );
  }

  TabBarView body() {
    return TabBarView(controller: _tabController, children: [cards(), table()]);
  }

  RefreshIndicator table() {
    return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            taskListHandler = taskListView(1).then((onValue) {
              setState(() {
                taskListDataSource = TaskListDataSource(
                  taskListData: taskList,
                  pageSize: _pageSize,
                  initialPage: 0,
                );
                selectedFilter = 1;
              });
            });
          });
        },
        child: FutureBuilder(
            future: taskListHandler,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return futureWaitingLoading();
              } else if (snapshot.hasError) {
                if (snapshot.error == 'Network Error') {
                  return futureDisplayError(content: snapshot.error.toString());
                } else {
                  return futureDisplayError(content: snapshot.error.toString());
                }
              } else {
                return taskList.isNotEmpty ? taskListing() : noDataError();
              }
            }));
  }

  Padding taskListing() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: search,
            onEditingComplete: () {
              setState(() {
                FocusManager.instance.primaryFocus!.unfocus();
              });
            },
            onTapOutside: (event) {
              setState(() {
                FocusManager.instance.primaryFocus!.unfocus();
              });
            },
            onChanged: (value) {
              setState(() {});
              searchTask();
            },
            decoration: InputDecoration(
              hintText: "Search",
              suffixIcon: search.text.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          search.clear();
                          taskListHandler =
                              taskListView(selectedFilter).then((onValue) {
                            taskListDataSource = TaskListDataSource(
                                taskListData: taskList,
                                pageSize: _pageSize,
                                initialPage: 0);
                          });
                        });
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Color(0xff2F4550),
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: whiteColor,
              prefixIcon: const Icon(Iconsax.search_normal),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: greenColor,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${taskList.length} entries",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: greenColor,
                    size: 10,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Text(
                    selectedFilter == 1
                        ? "Received"
                        : selectedFilter == 2
                            ? "Submitted"
                            : selectedFilter == 3
                                ? "Pending"
                                : selectedFilter == 4
                                    ? "Completed"
                                    : selectedFilter == 5
                                        ? "Rejected"
                                        : selectedFilter == 6
                                            ? "Reminder"
                                            : selectedFilter == 7
                                                ? "Cancelled"
                                                : "",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SfDataGrid(
              key: key,
              allowSorting: true,
              frozenColumnsCount: 1,
              headerGridLinesVisibility: GridLinesVisibility.both,
              gridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: ColumnWidthMode.fitByColumnName,
              rowHeight: 65,
              source: taskListDataSource,
              columns: <GridColumn>[
                GridColumn(
                    width: 100,
                    columnName: 'sno',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Sno',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'viewTask',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'subject',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Subject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'recipient',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          tableHead,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'department',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Department',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'description',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'priority',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Priority',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'startDate',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Start Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'endDate',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'End Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'kpiClock',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Kpi Clock',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    width: 100,
                    columnName: 'start',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Start',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'completedExtend',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Completed / Extend',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    width: 100,
                    columnName: 'reallocation',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Reallocation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    width: 100,
                    columnName: 'reject',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'nextStep',
                    label: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Next Step',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),
          PaginationControls(
            currentPage: currentPage,
            totalPages: taskListDataSource.totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }

  FutureBuilder<dynamic> cards() {
    return FutureBuilder(
      future: dashboardCountHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureWaitingLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureDisplayError(content: snapshot.error.toString());
          } else {
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                dashboardCountHandler = dashboardCountListView();
                currentPage = 0;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(1).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 1;
                              });
                            });
                          },
                          child: Widgets().cardContainer(
                              dashboardCountList.first.receivedCount ??
                                  0.toString(),
                              "Received",
                              greenCardColor)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(2).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 2;
                              });
                            });
                          },
                          child: Widgets().cardContainer(
                              dashboardCountList.first.submittedCount ??
                                  0.toString(),
                              "Submitted",
                              yellowCardColor)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(3).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 3;
                              });
                            });
                          },
                          child: Widgets().cardContainer(
                              dashboardCountList.first.pendingCount ??
                                  0.toString(),
                              "Pending",
                              yellowCardColor)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(4).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 4;
                              });
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Widgets().cardContainer(
                              dashboardCountList.first.completedCount ??
                                  0.toString(),
                              "Completed",
                              yellowCardColor)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(5).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 5;
                              });
                            });
                          },
                          child: Widgets().cardContainer(
                              dashboardCountList.first.rejectedCount ??
                                  0.toString(),
                              "Rejected",
                              yellowCardColor)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(6).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 6;
                              });
                            });
                          },
                          child: Widgets().cardContainer(
                              dashboardCountList.first.reminderCount ??
                                  0.toString(),
                              "Reminder",
                              yellowCardColor)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                            setState(() {
                              taskListHandler = taskListView(7).then((onValue) {
                                taskListDataSource = TaskListDataSource(
                                    taskListData: taskList,
                                    pageSize: _pageSize,
                                    initialPage: 0);
                                selectedFilter = 7;
                              });
                            });
                          },
                          child: Widgets().cardContainer(
                              dashboardCountList.first.cancelledCount ??
                                  0.toString(),
                              "Cancelled",
                              yellowCardColor)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        height: 120,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          );
        }
      },
    );
  }

  Column floatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: null,
          foregroundColor: whiteColor,
          backgroundColor: greenColor,
          shape: const CircleBorder(),
          onPressed: () {
            exportDataGridToExcel();
          },
          child: const Icon(Iconsax.document_download),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          heroTag: null,
          foregroundColor: whiteColor,
          backgroundColor: greenColor,
          shape: const CircleBorder(),
          onPressed: () {
            openTaskForm();
          },
          child: const Icon(Iconsax.add),
        ),
      ],
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: whiteColor),
      backgroundColor: greenColor,
      title: const Text(
        "Dashboard",
        style: TextStyle(color: whiteColor),
      ),
      bottom: TabBar(
        labelColor: whiteColor,
        indicatorColor: whiteColor,
        unselectedLabelColor: whiteColor,
        controller: _tabController,
        tabs: const [
          Tab(
            text: "Main",
          ),
          Tab(
            text: "Task List",
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
          icon: const Icon(Iconsax.menu),
        ),
      ],
    );
  }

  Future dashboardCountListView() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    try {
      setState(() {
        dashboardCountList.clear();
        currentVersion = packageInfo.version;
      });

      return await DashboardService()
          .getDashboardCount()
          .then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          var data = resultData["head"]["msg"];
          DashboardCountModel model = DashboardCountModel();
          model.receivedCount = data["received_count"].toString();
          model.cancelledCount = data["cancelled_count"].toString();
          model.pendingCount = data["pending_count"].toString();
          model.completedCount = data["completed_count"].toString();
          model.rejectedCount = data["rejected_count"].toString();
          model.reminderCount = data["reminder_count"].toString();
          model.submittedCount = data["submitted_count"].toString();
          model.showInsights =
              data["check_insights"].toString() == "1" ? true : false;

          setState(() {
            dashboardCountList.add(model);
          });
        } else if (resultData["head"]["code"] == 400) {
          setState(() {
            dashboardCountList.clear();
          });
          showSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
        }
      });
    } on SocketException catch (e) {
      throw "Network Error";
    } catch (e) {
      throw e.toString();
    }
  }

  Future taskListView(int? filter) async {
    setState(() {
      taskList.clear();
    });

    try {
      return await DashboardService()
          .getTaskList(filter)
          .then((resultData) async {
        if (resultData["head"]["code"] == 200) {
          if (resultData["head"]["msg"].isNotEmpty) {
            if (resultData["head"]["msg"]["table_head"] != "") {
              setState(() {
                tableHead = resultData["head"]["msg"]["table_head"];
              });
            }

            for (var data in resultData["head"]["msg"]["task_list"]) {
              setState(() {
                taskList.add(TaskList(
                    data["reminder_count"] == ""
                        ? "${data["request_number"].toString()}/"
                        : "${data["request_number"].toString()}/${data["reminder_count"].toString()}",
                    GestureDetector(
                      onTap: () {
                        openTaskEditForm(data["task_tracker_id"].toString());
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: greenColor,
                        ),
                        child: const Center(
                          child: Text(
                            "View",
                            style: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    data["subject"].toString(),
                    data["filter"] == 'filter2' ||
                            data["filter"] == 'filter3' ||
                            data["filter"] == 'filter4'
                        ? data["full_recipient_name"]
                        : data["requestor_name"],
                    data["department_name"].toString(),
                    data["description"].toString(),
                    data["priority_level"].toString(),
                    data["start_date"].toString(),
                    data["end_date"].toString(),
                    data["task_duration"].toString(),
                    data["show_start_button"] == 1
                        ? GestureDetector(
                            onTap: () {
                              startTask(data['task_tracker_id']);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: greenColor,
                              ),
                              child: const Center(
                                child: Text(
                                  "Start",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : data["start_time"].toString() != ''
                            ? Text(data["start_time"].toString())
                            : Container(),
                    data["show_complete_button"] == 1
                        ? GestureDetector(
                            onTap: () {
                              completeTask(data["task_tracker_id"]);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: greenColor,
                              ),
                              child: const Center(
                                child: Text(
                                  "Complete",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : data["end_time"].toString() != ''
                            ? Text(data["end_time"].toString())
                            : Container(),
                    data["show_reallocate_button"] == 1
                        ? GestureDetector(
                            onTap: () {
                              reallocateTask(data["task_tracker_id"]);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: redColor,
                              ),
                              child: const Center(
                                child: Text(
                                  "Reallocate",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    data["show_reject_button"] == 1
                        ? GestureDetector(
                            onTap: () {
                              rejectTask(data["task_tracker_id"]);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: redColor,
                              ),
                              child: const Center(
                                child: Text(
                                  "Reject",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    data["next_recipient_name"]));
              });
            }
          }
        } else if (resultData["head"]["code"] == 400) {
          showSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
        }
      });
    } on SocketException catch (e) {
      throw "Network Error";
    } catch (e) {
      throw e.toString();
    }
  }

  startTask(String taskId) async {
    try {
      futureLoading(context);
      await DashboardService().startTask(taskId).then((onValue) {
        if (onValue["head"]["code"] == 200) {
          Navigator.pop(context);
          showSnackBar(context,
              content: onValue["head"]["msg"].toString(), isSuccess: true);

          setState(() {
            dashboardCountHandler = dashboardCountListView();
            taskListHandler = taskListView(1).then((onValue) {
              taskListDataSource = TaskListDataSource(
                  taskListData: taskList, pageSize: _pageSize, initialPage: 0);
              selectedFilter = 1;
            });
          });
        } else {
          Navigator.pop(context);
          showSnackBar(context,
              content: onValue["head"]["msg"].toString(), isSuccess: false);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  completeTask(String taskId) async {
    futureLoading(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TaskcompleteDialog(taskId: taskId);
      },
    ).then((onValue) async {
      Navigator.pop(context);
      if (onValue) {
        showSnackBar(context, content: "Task Completed", isSuccess: true);
        setState(() {
          dashboardCountHandler = dashboardCountListView();
          taskListHandler = taskListView(1).then((onValue) {
            taskListDataSource = TaskListDataSource(
                taskListData: taskList, pageSize: _pageSize, initialPage: 0);
            selectedFilter = 1;
          });
        });
      } else {
        showSnackBar(context,
            content: "Sorry updation not complete. Please try again",
            isSuccess: false);
      }
    });
  }

  reallocateTask(String taskId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReallocationDialog(taskId: taskId),
    ).then((onValue) {
      if (onValue) {
        showSnackBar(context, content: "Updated Successfully", isSuccess: true);
        setState(() {
          dashboardCountHandler = dashboardCountListView();
          taskListHandler = taskListView(1).then((onValue) {
            taskListDataSource = TaskListDataSource(
                taskListData: taskList, pageSize: _pageSize, initialPage: 0);
            selectedFilter = 1;
          });
        });
      } else {
        showSnackBar(context,
            content: "Sorry updation not completed. Please try again",
            isSuccess: false);
      }
    });
  }

  rejectTask(String taskId) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ConfirmDialog(
              title: "Reject",
              content: "Are you sure want to reject task?",
            )).then((onValue) async {
      if (onValue) {
        futureLoading(context);

        await DashboardService().rejectTask(taskId).then((onValue) {
          if (onValue["head"]["code"] == 200) {
            Navigator.pop(context);

            showSnackBar(context,
                content: onValue["head"]["msg"], isSuccess: true);
            setState(() {
              dashboardCountHandler = dashboardCountListView();
              taskListHandler = taskListView(1).then((onValue) {
                taskListDataSource = TaskListDataSource(
                    taskListData: taskList,
                    pageSize: _pageSize,
                    initialPage: 0);
                selectedFilter = 1;
              });
            });
          } else {
            Navigator.pop(context);

            showSnackBar(context,
                content: onValue["head"]["msg"], isSuccess: true);
          }
        });
      }
    });
  }

  @override
  initState() {
    super.initState();
    dashboardCountHandler = dashboardCountListView().whenComplete(initData);
    taskListHandler = taskListView(1).then((onValue) {
      taskListDataSource = TaskListDataSource(
          taskListData: taskList, pageSize: _pageSize, initialPage: 0);
      selectedFilter = 1;
    });
    _tabController = TabController(length: 2, vsync: this);
    getEmployee();
  }

  initData() {
    if (dashboardCountList.isNotEmpty) {
      setState(() {
        showInsights = dashboardCountList.first.showInsights;
      });
    }
  }

  getEmployee() async {
    name = await LocalDBConfig().getName() ?? '';
    email = await LocalDBConfig().getEmail() ?? '';
    setState(() {});
  }

  openTaskEditForm(String? taskId) async {
    await showModalBottomSheet(
      backgroundColor: whiteColor,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(20),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return TaskEdit(
          taskId: taskId!,
          selectedFilter: selectedFilter,
        );
      },
    ).then((onValue) {
      if (onValue != null) {
        if (onValue) {
          dashboardCountHandler = dashboardCountListView();
          taskListHandler = taskListView(1).then((onValue) {
            taskListDataSource = TaskListDataSource(
                taskListData: taskList, pageSize: _pageSize, initialPage: 0);
            selectedFilter = 1;
          });
        }
      }
    });
  }

  openTaskForm() async {
    await showModalBottomSheet(
      backgroundColor: whiteColor,
      useSafeArea: true,
      enableDrag: false,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(20),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const TaskView();
      },
    ).then((onValue) {
      if (onValue != null) {
        if (onValue) {
          dashboardCountHandler = dashboardCountListView();
          taskListHandler = taskListView(1).then((onValue) {
            taskListDataSource = TaskListDataSource(
                taskListData: taskList, pageSize: _pageSize, initialPage: 0);
            selectedFilter = 1;
          });
        }
      }
    });
  }

  Future exportDataGridToExcel() async {
    if (key.currentState != null) {
      final Workbook workbook = key.currentState!.exportToExcelWorkbook(
          exportStackedHeaders: true,
          excludeColumns: [
            "completedExtend",
            "start",
            "reallocation",
            "reject",
            "viewTask"
          ]);
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.saveAndLaunchFile(bytes, 'TaskConnect.xlsx');
    } else {
      showSnackBar(context,
          content: "Please select filter before download", isSuccess: false);
    }
  }

  @override
  dispose() {
    _tabController.dispose();
    super.dispose();
  }

  searchTask() {
    List<TaskList> filteredList = taskList.where((task) {
      return task.sno.toLowerCase().contains(search.text.toLowerCase()) ||
          task.subject.toLowerCase().contains(search.text.toLowerCase());
    }).toList();

    setState(() {
      taskListDataSource = TaskListDataSource(
          taskListData: filteredList,
          pageSize: _pageSize,
          initialPage: currentPage);
    });
  }

  onPageChanged(int newPage) {
    setState(() {
      currentPage = newPage;
      taskListDataSource.goToPage(currentPage);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TaskListDataSource taskListDataSource =
      TaskListDataSource(taskListData: [], pageSize: 10, initialPage: 0);
  late TabController _tabController;
  String name = "", email = "", tableHead = "";
  List<DashboardCountModel> dashboardCountList = [];
  List<TaskList> taskList = <TaskList>[];
  List<TaskList> paginatedTaskList = <TaskList>[];
  Future? dashboardCountHandler;
  Future? taskListHandler;
  TextEditingController search = TextEditingController();
  int selectedFilter = 1;
  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();
  bool? showInsights = false;
  int currentPage = 0;
  final int _pageSize = 10;
  String? currentVersion;
}
