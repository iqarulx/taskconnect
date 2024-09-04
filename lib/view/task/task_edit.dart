/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/models/task_model.dart';
import '/providers/file_picker.dart';
import '/services/http/task_service.dart';
import '/services/local_db/local_db.dart';
import '/view/task/file_preview.dart';
import '/view/utils/colors.dart';
import '/view/utils/error_display.dart';
import '/view/utils/loading.dart';
import '/view/utils/snackbar.dart';

class TaskEdit extends StatefulWidget {
  final String taskId;
  final int selectedFilter;
  const TaskEdit(
      {super.key, required this.taskId, required this.selectedFilter});

  @override
  State<TaskEdit> createState() => _TaskEditState();
}

class _TaskEditState extends State<TaskEdit> {
  final TextEditingController subject = TextEditingController();
  final TextEditingController description = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<bool>? taskEditHandler;
  List<TaskModel> taskDataList = [];
  List<CompanyModel> companyDataList = [];
  List<DepartmentModel> departmentDataList = [];
  List<UserModel> userDataList = [];
  String? selectedCompanyId;
  String? selectedCompany;
  String? selectedDepartmentId;
  String? selectedDepartment;
  String? selectedPriority;
  List<File> files = [];
  List<dynamic> previousFiles = [];
  List<dynamic> selectedUserIds = [];
  List<String> uploadFiles = [];
  List<dynamic> recipientAttachments = [];

  @override
  void initState() {
    taskEditHandler = taskEditView().whenComplete(initData);
    super.initState();
  }

  initData() {
    setState(() {
      subject.text = taskDataList.first.subject!;
      startDate.text = taskDataList.first.startDate!;
      endDate.text = taskDataList.first.endDate!;
      description.text = taskDataList.first.description!;
      selectedPriority = taskDataList.first.priority;
      selectedCompanyId = taskDataList.first.companyId;
      selectedDepartmentId = taskDataList.first.department;
      selectedUserIds = taskDataList.first.recepients!;
      previousFiles = taskDataList.first.files!;
      recipientAttachments = taskDataList.first.recepientAttachments!;
    });
  }

  Future<bool> taskEditView() async {
    try {
      setState(() {
        taskDataList.clear();
      });

      var resultData = await TaskService().getTaskData(widget.taskId);

      if (resultData != null && resultData["head"]["code"] == 200) {
        var taskData = resultData["head"]["msg"]["task_tracker_list"];
        TaskModel taskModel = TaskModel();
        taskModel.subject = taskData[0]["subject"].toString();
        taskModel.companyId = taskData[0]["company_id"].toString();
        taskModel.description = taskData[0]["description"].toString();
        taskModel.priority = taskData[0]["priority_level"].toString();
        taskModel.department = taskData[0]["department_id"].toString();
        taskModel.startDate = taskData[0]["start_date"].toString();
        taskModel.endDate = taskData[0]["completion_date"].toString();
        taskModel.files = taskData[0]["attachment"];
        taskModel.recepients = taskData[0]["recipient"];
        taskModel.recepientAttachments =
            resultData["head"]["msg"]["recipient_attachment"];

        setState(() {
          taskDataList.add(taskModel);
        });

        for (var companyData in resultData["head"]["msg"]["company_list"]) {
          CompanyModel companyModel = CompanyModel();
          companyModel.companyName = companyData["company_name"].toString();
          companyModel.companyId = companyData["company_id"].toString();

          setState(() {
            companyDataList.add(companyModel);
          });
        }

        for (var departmentData in resultData["head"]["msg"]
            ["department_list"]) {
          DepartmentModel departmentModel = DepartmentModel();
          departmentModel.departmentName =
              departmentData["department_name"].toString();
          departmentModel.departmentId =
              departmentData["department_id"].toString();
          departmentModel.companyId = departmentData["company_id"].toString();
          setState(() {
            departmentDataList.add(departmentModel);
          });
        }

        for (var userData in resultData["head"]["msg"]["employee_list"]) {
          var userId = userData["employee_id"].toString();
          UserModel userModel = UserModel();
          userModel.userId = userId;
          userModel.userName = userData["full_name"].toString();
          setState(() {
            userDataList.add(userModel);
          });
        }

        return true;
      } else if (resultData != null && resultData["head"]["code"] == 400) {
        showSnackBar(context,
            content: resultData["head"]["msg"].toString(), isSuccess: false);
        throw resultData["head"]["msg"].toString();
      }
      return true;
    } on SocketException catch (e) {
      throw "Network Error";
    } catch (e) {
      throw e.toString();
    }
  }

  submitForm() async {
    if (selectedUserIds.isNotEmpty) {
      futureLoading(context);
      var employeeId = await LocalDBConfig().getUserId();

      uploadFiles.clear();

      if (files.isNotEmpty) {
        for (int index = 0; index < files.length; index++) {
          var file = files[index];
          var onValue =
              await FilePickerService().uploadFile(file, "attachment", index);
          uploadFiles.add(onValue);
        }
      }

      uploadFiles.addAll(previousFiles.map((file) => file.toString()));

      try {
        Map<String, dynamic> formData = {
          "task_tracker_edit_id": widget.taskId,
          "employee_id": employeeId,
          "attachment": uploadFiles,
        };

        await TaskService().updateTask(formData).then((onValue) {
          if (onValue["head"]["code"] == 200) {
            Navigator.pop(context);
            showSnackBar(context,
                content: onValue["head"]["msg"], isSuccess: true);
            Navigator.pop(context, true);
          } else {
            Navigator.pop(context);
            showSnackBar(context,
                content: onValue["head"]["msg"], isSuccess: false);
          }
        });
      } catch (e) {
        Navigator.pop(context);
        showSnackBar(context, content: e.toString(), isSuccess: false);
      }
    } else {
      showSnackBar(context,
          content: "Please select recipients", isSuccess: false);
    }
  }

  reminderTask() async {
    var employeeId = await LocalDBConfig().getUserId();
    try {
      futureLoading(context);

      Map<String, dynamic> formData = {
        "task_tracker_reminder_id": widget.taskId,
        "employee_id": employeeId,
      };

      await TaskService().reminderTask(formData).then((onValue) {
        if (onValue["head"]["code"] == 200) {
          Navigator.pop(context);
          showSnackBar(context,
              content: onValue["head"]["msg"], isSuccess: true);
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
          showSnackBar(context,
              content: onValue["head"]["msg"], isSuccess: false);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  cancelTask() async {
    var employeeId = await LocalDBConfig().getUserId();
    try {
      futureLoading(context);

      Map<String, dynamic> formData = {
        "task_tracker_cancel_id": widget.taskId,
        "employee_id": employeeId,
      };

      await TaskService().cancelTask(formData).then((onValue) {
        if (onValue["head"]["code"] == 200) {
          Navigator.pop(context);
          showSnackBar(context,
              content: onValue["head"]["msg"], isSuccess: true);
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
          showSnackBar(context,
              content: onValue["head"]["msg"], isSuccess: false);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appbar(context),
            bottomNavigationBar: widget.selectedFilter != 4 &&
                    widget.selectedFilter != 5 &&
                    widget.selectedFilter != 7
                ? bottomaAppbar(context)
                : null,
            body: FutureBuilder<bool>(
                future: taskEditHandler,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    if (snapshot.error == 'Network Error') {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    } else {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    }
                  } else {
                    // print(
                    //     "SelectedId : $selectedDepartmentId SelectedId : $selectedCompanyId");
                    // print("Before ${departmentDataList.map(
                    //       (department) =>
                    //           "${department.departmentId}${department.departmentName}${department.companyId}",
                    //     ).toList()}");
                    // print(
                    //     "After ${departmentDataList.where((department) => department.companyId == selectedCompanyId).map(
                    //           (department) => "${department.departmentId}",
                    //         ).toList()}");
                    return screenView(context);
                  }
                })),
      ),
    );
  }

  Padding screenView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
                key: _formKey,
                child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      firstScreen(context),
                      secondTab(context),
                    ])),
          )),
    );
  }

  SingleChildScrollView firstScreen(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        entityFeild(context),
        const SizedBox(height: 14),
        subjectFeild(context),
        const SizedBox(height: 14),
        descriptionFeild(context),
        const SizedBox(height: 14),
        departmentFeild(context),
        const SizedBox(height: 14),
        priorityFeild(context),
        const SizedBox(height: 14),
        dateFeild(context),
        const SizedBox(height: 14),
        uploadFilesFeild(context),
      ],
    ));
  }

  SingleChildScrollView secondTab(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Recipients",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    endIndent: 0,
                    color: Colors.white,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Action",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                for (int i = 0; i < selectedUserIds.length; i++)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedUserIds[i],
                            dropdownColor: Colors.white,
                            onChanged: null,
                            decoration: InputDecoration(
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
                                  color: Colors.green,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: userDataList
                                .map((user) => DropdownMenuItem(
                                      value: user.userId,
                                      child: Text(user.userName!),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select user';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      )
                    ],
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Column uploadFilesFeild(BuildContext context) {
    return Column(
      children: [
        Text(
          "Upload Files",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          onTap: () async {
            await FilePickerService().pickFiles(context).then((onValue) {
              if (onValue != null) {
                if (onValue.isNotEmpty) {
                  setState(() {
                    files = onValue;
                  });
                }
              }
            });
          },
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
          decoration: InputDecoration(
              hintText: "Upload File",
              filled: true,
              hintStyle: TextStyle(color: Colors.grey[500]),
              fillColor: Colors.grey.shade200,
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
              suffixIcon: Icon(
                Iconsax.document_upload,
                color: Colors.grey[500],
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 20.0,
            maxHeight: 200.0,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await showModalBottomSheet(
                    backgroundColor: Colors.white,
                    useSafeArea: true,
                    shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (builder) {
                      return FilePreview(
                        file: files[index],
                        networkFile: null,
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          files[index].path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          setState(() {
                            files.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (previousFiles.isNotEmpty)
          Column(
            children: [
              const Text(
                "Previous Uploads",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  maxHeight: 200.0,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: previousFiles.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await showModalBottomSheet(
                          backgroundColor: Colors.white,
                          useSafeArea: true,
                          shape: RoundedRectangleBorder(
                            side: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isScrollControlled: true,
                          context: context,
                          builder: (builder) {
                            return FilePreview(
                              file: null,
                              networkFile: previousFiles[index],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                previousFiles[index],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Iconsax.close_circle),
                              onPressed: () {
                                setState(() {
                                  previousFiles.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        if (recipientAttachments.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 40.0,
              maxHeight: 200.0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recipientAttachments.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    await showModalBottomSheet(
                      backgroundColor: Colors.white,
                      useSafeArea: true,
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isScrollControlled: true,
                      context: context,
                      builder: (builder) {
                        return FilePreview(
                          file: null,
                          networkFile: recipientAttachments[index],
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recipientAttachments[index],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.close_circle),
                          onPressed: () {
                            setState(() {
                              recipientAttachments.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Row dateFeild(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Start Date",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Colors.black54),
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: startDate,
                readOnly: true,
                enabled: false,
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
                decoration: InputDecoration(
                  hintText: "Start Date",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey.shade200,
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
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please select date';
                  }
                  return null;
                },
                // onTap: () => startDatePicker(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Completion Date",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Colors.black54),
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: endDate,

                readOnly: true,
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
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Completion Date",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey.shade200,
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
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please select date';
                  }
                  return null;
                },
                // onTap: () => endDatePicker(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column priorityFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Priority",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedPriority,
          dropdownColor: Colors.white,
          onChanged: null,
          decoration: InputDecoration(
            // labelText: 'Entity',
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
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
          validator: (value) {
            if (value == null || value == '') {
              return 'Please select priority';
            }
            return null;
          },
          items: [
            DropdownMenuItem(
              value: selectedPriority,
              child: Text(
                selectedPriority!,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column departmentFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Department",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDepartmentId,
          dropdownColor: Colors.white,
          onChanged: null,
          decoration: InputDecoration(
            // labelText: 'Entity',
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
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
          items: departmentDataList
              // .where((department) => department.companyId == selectedCompanyId)
              .map((department) => DropdownMenuItem(
                    value: department.departmentId,
                    child: Text(department.departmentName!),
                  ))
              .toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select department';
            }
            return null;
          },
        ),
      ],
    );
  }

  Column descriptionFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: description,
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
          maxLines: 5,
          enabled: false,
          decoration: InputDecoration(
            hintText: "Description",
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey.shade200,
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
      ],
    );
  }

  Column subjectFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subject",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: subject,
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
          enabled: false,
          decoration: InputDecoration(
            hintText: "Subject",
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey.shade200,
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
      ],
    );
  }

  Column entityFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Entity",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCompanyId,
          dropdownColor: Colors.white,
          onChanged: null,
          decoration: InputDecoration(
            // labelText: 'Entity',
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
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
          items: companyDataList
              .map((company) => DropdownMenuItem(
                    value: company.companyId,
                    child: Text(company.companyName!),
                  ))
              .toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select entity';
            }
            return null;
          },
        ),
      ],
    );
  }

  BottomAppBar bottomaAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Row(
        children: [
          if (widget.selectedFilter == 2 || widget.selectedFilter == 3)
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      reminderTask();
                    },
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.clock,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Reminder",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.selectedFilter == 2 || widget.selectedFilter == 3)
            const SizedBox(
              width: 5,
            ),
          if (widget.selectedFilter == 2 || widget.selectedFilter == 3)
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      cancelTask();
                    },
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.close_circle,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Cancel",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.selectedFilter == 2 || widget.selectedFilter == 3)
            const SizedBox(
              width: 5,
            ),
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      submitForm();
                    }
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Submit",
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashRadius: 20,
              constraints: const BoxConstraints(
                maxWidth: 40,
                maxHeight: 40,
                minWidth: 40,
                minHeight: 40,
              ),
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.pop(context, false);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        "TASK TRACKER - REQUESTER",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
      bottom: const TabBar(
        labelColor: Colors.black,
        indicatorColor: Colors.black,
        unselectedLabelColor: Colors.black38,
        tabs: [
          Tab(
            text: "Form",
          ),
          Tab(
            text: "Recipients",
          ),
        ],
      ),
    );
  }
}
