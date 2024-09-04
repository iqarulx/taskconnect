/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '/models/task_model.dart';
import '/providers/file_picker.dart';
import '/services/http/task_service.dart';
import '/services/local_db/local_db.dart';
import '/view/task/file_preview.dart';
import '/view/utils/colors.dart';
import '/view/utils/error_display.dart';
import '/view/utils/loading.dart';
import '/view/utils/snackbar.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
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
  String selectedPriority = "1";
  List<File> files = [];
  List<String> selectedUserIds = [];
  List<List<String>> selectedUsersRows = [];
  List<String> uploadFiles = [];

  @override
  void initState() {
    taskEditHandler = taskEditView();
    super.initState();
  }

  Future<bool> taskEditView() async {
    try {
      setState(() {
        taskDataList.clear();
      });

      var resultData = await TaskService().getTaskData('');

      if (resultData != null && resultData["head"]["code"] == 200) {
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
          var employeeId = await LocalDBConfig().getUserId();
          var userId = userData["employee_id"].toString();

          if (!employeeId!.contains(userId)) {
            UserModel userModel = UserModel();
            userModel.userId = userId;
            userModel.userName = userData["full_name"].toString();
            setState(() {
              userDataList.add(userModel);
            });
          }
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

  addRecipientRow() {
    // if (selectedUserIds.isNotEmpty) {
    setState(() {
      selectedUsersRows.add([...selectedUserIds]);
      // selectedUserIds.clear();
    });
  }

  removeRecipientRow(int index) {
    setState(() {
      selectedUsersRows.removeAt(index);
      if (index >= 0 && index < selectedUserIds.length) {
        selectedUserIds.removeAt(index);
      }
    });
  }

  Future<DateTime?> datePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
    );
    return picked;
  }

  Future<DateTime?> completionDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat("dd-MM-yyyy").parse(startDate.text),
      firstDate: DateFormat("dd-MM-yyyy").parse(startDate.text),
      lastDate: DateTime(2100, 12, 31),
    );
    return picked;
  }

  startDatePicker() async {
    endDate.clear();
    final DateTime? picked = await datePicker();
    if (picked != null) {
      setState(() {
        startDate.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  endDatePicker() async {
    if (startDate.text.isNotEmpty) {
      final DateTime? picked = await completionDatePicker();

      if (picked != null) {
        setState(() {
          endDate.text = DateFormat('dd-MM-yyyy').format(picked);
        });
      }
    } else {
      showSnackBar(context,
          content: "Please select start date first", isSuccess: false);
    }
  }

  submitForm() async {
    if (selectedCompanyId != null &&
        selectedDepartmentId != null &&
        startDate.text.isNotEmpty &&
        endDate.text.isNotEmpty) {
      if (selectedUserIds.isNotEmpty) {
        if (selectedUsersRows.length == selectedUserIds.length) {
          futureLoading(context);
          var employeeId = await LocalDBConfig().getUserId();
          uploadFiles.clear();
          if (files.isNotEmpty) {
            for (int index = 0; index < files.length; index++) {
              var file = files[index];
              var onValue = await FilePickerService()
                  .uploadFile(file, "attachment", index);
              uploadFiles.add(onValue);
            }
          }

          try {
            Map<String, dynamic> formData = {
              "task_tracker_edit_id": '',
              "employee_id": employeeId,
              "company_id": selectedCompanyId,
              "subject": subject.text,
              "description": description.text,
              "department": selectedDepartmentId,
              "priority": selectedPriority,
              "start_date": startDate.text,
              "end_date": endDate.text,
              "attachment": uploadFiles,
              "recipients": selectedUserIds
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
              content: "Add or remove recipients. Don't be empty",
              isSuccess: false);
        }
      } else {
        showSnackBar(context,
            content: "Please select recipients", isSuccess: false);
      }
    } else {
      showSnackBar(context,
          content: "Please fill all fields", isSuccess: false);
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
            bottomNavigationBar: bottomaAppbar(context),
            body: body()),
      ),
    );
  }

  FutureBuilder<bool> body() {
    return FutureBuilder<bool>(
        future: taskEditHandler,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            if (snapshot.error == 'Network Error') {
              return futureDisplayError(content: snapshot.error.toString());
            } else {
              return futureDisplayError(content: snapshot.error.toString());
            }
          } else {
            return screenView(context);
          }
        });
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
                      firstTab(context),
                      secondTab(context),
                    ])),
          )),
    );
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
                      "Select Recipients",
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
                for (int i = 0; i < selectedUsersRows.length; i++)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomDropdown<String>.search(
                              hintText: 'Select user',
                              initialItem: i != selectedUserIds.length
                                  ? userDataList
                                      .firstWhere((user) =>
                                          user.userId == selectedUserIds[i])
                                      .userName
                                  : null,
                              items: userDataList
                                  .map((user) => user.userName!)
                                  .toList(),
                              decoration: CustomDropdownDecoration(
                                expandedBorderRadius: BorderRadius.circular(10),
                                expandedBorder:
                                    Border.all(color: Colors.grey.shade300),
                                closedBorderRadius: BorderRadius.circular(10),
                                closedBorder:
                                    Border.all(color: Colors.grey.shade200),
                                closedSuffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black,
                                ),
                                expandedSuffixIcon: const Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Colors.black,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                listItemStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                searchFieldDecoration:
                                    const SearchFieldDecoration(
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              overlayHeight: 342,
                              onChanged: (value) {
                                if (value != null) {
                                  var userId = userDataList
                                      .firstWhere(
                                          (user) => user.userName == value)
                                      .userId;
                                  setState(() {
                                    if (i < selectedUserIds.length) {
                                      selectedUserIds[i] = userId!;
                                    } else {
                                      selectedUserIds.add(userId!);
                                    }
                                  });
                                }
                              },
                            )),
                      ),
                      const VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      if (i != 0)
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                removeRecipientRow(i);
                              },
                              icon: const Icon(
                                Iconsax.trash,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          flex: 1,
                          child: Container(),
                        )
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      selectedUsersRows.length == selectedUserIds.length
                          ? addRecipientRow()
                          : null;
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
                              Icons.add_circle,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Add Recipient",
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
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  ListView firstTab(BuildContext context) {
    return ListView(
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
    );
  }

  Column uploadFilesFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            minHeight: 40.0,
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
                readOnly: true,
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
                onTap: () => startDatePicker(),
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
                readOnly: true,
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
                onTap: () => endDatePicker(),
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
        CustomDropdown<String>.search(
          hintText: 'Select Priority',
          items: const ['1', '2', '3', '4'],
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey.shade200,
            expandedBorderRadius: BorderRadius.circular(10),
            expandedBorder: Border.all(color: Colors.grey.shade300),
            closedBorderRadius: BorderRadius.circular(10),
            closedBorder: Border.all(color: Colors.grey.shade200),
            closedSuffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            expandedSuffixIcon: const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.black,
            ),
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
            listItemStyle: const TextStyle(
              color: Colors.black,
            ),
            searchFieldDecoration: const SearchFieldDecoration(
              textStyle: TextStyle(
                color: Colors.black,
              ),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          overlayHeight: 342,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedPriority = value;
              });
            }
          },
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
        CustomDropdown<String>.search(
          hintText: 'Select department',
          initialItem: selectedDepartmentId != null
              ? departmentDataList
                  .firstWhere((department) =>
                      department.departmentId == selectedDepartmentId)
                  .departmentName
              : null,
          items: departmentDataList
              .where((department) => department.companyId == selectedCompanyId)
              .map((department) => department.departmentName!)
              .toList(),
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey.shade200,
            expandedBorderRadius: BorderRadius.circular(10),
            expandedBorder: Border.all(color: Colors.grey.shade300),
            closedBorderRadius: BorderRadius.circular(10),
            closedBorder: Border.all(color: Colors.grey.shade200),
            closedSuffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            expandedSuffixIcon: const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.black,
            ),
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
            listItemStyle: const TextStyle(
              color: Colors.black,
            ),
            searchFieldDecoration: const SearchFieldDecoration(
              textStyle: TextStyle(
                color: Colors.black,
              ),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          overlayHeight: 342,
          onChanged: (value) {
            if (value != null) {
              var departmentId = departmentDataList
                  .firstWhere(
                      (department) => department.departmentName == value)
                  .departmentId;
              setState(() {
                selectedDepartmentId = departmentId;
              });
            }
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
        CustomDropdown<String>.search(
          hintText: 'Select entity',
          initialItem: selectedCompanyId != null
              ? companyDataList
                  .firstWhere(
                      (company) => company.companyId == selectedCompanyId)
                  .companyName
              : null,
          items:
              companyDataList.map((company) => company.companyName!).toList(),
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey.shade200,
            expandedBorderRadius: BorderRadius.circular(10),
            expandedBorder: Border.all(color: Colors.grey.shade300),
            closedBorderRadius: BorderRadius.circular(10),
            closedBorder: Border.all(color: Colors.grey.shade200),
            closedSuffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            expandedSuffixIcon: const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.black,
            ),
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
            listItemStyle: const TextStyle(
              color: Colors.black,
            ),
            searchFieldDecoration: const SearchFieldDecoration(
              textStyle: TextStyle(
                color: Colors.black,
              ),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          overlayHeight: 342,
          onChanged: (value) {
            if (value != null) {
              var companyId = companyDataList
                  .firstWhere((company) => company.companyName == value)
                  .companyId;
              setState(() {
                selectedDepartment = null;
                selectedDepartmentId = null;
                selectedCompanyId = companyId;
              });
            }
          },
        ),
      ],
    );
  }

  BottomAppBar bottomaAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
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
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
