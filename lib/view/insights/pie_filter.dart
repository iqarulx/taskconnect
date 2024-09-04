/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/models/task_model.dart';
import '/services/http/insights_service.dart';
import '/view/utils/colors.dart';
import '/view/utils/error_display.dart';
import '/view/utils/loading.dart';
import '/view/utils/snackbar.dart';

class PieFilter extends StatefulWidget {
  const PieFilter({super.key});

  @override
  State<PieFilter> createState() => _PieFilterState();
}

class _PieFilterState extends State<PieFilter> {
  List<CompanyModel> companyDataList = [];
  List<DepartmentModel> departmentDataList = [];
  List<UserModel> userDataList = [];
  List<String> taskMonthYearList = [];
  Future? formDataHandler;
  String? selectedCompanyId;
  String? selectedCompany;
  String? selectedDepartmentId;
  String? selectedDepartment;
  String? selectedUserId;
  String? selectedUser;
  String? selectedTaskMonthYear;

  @override
  void initState() {
    formDataHandler = getForm();
    super.initState();
  }

  Future getForm() async {
    try {
      setState(() {
        companyDataList.clear();
        departmentDataList.clear();
        userDataList.clear();
        taskMonthYearList.clear();
      });

      return await InsightsService()
          .getChartData(formData: {"task_chart": 1}).then((resultData) async {
        if (resultData.isNotEmpty && resultData["head"]["code"] == 200) {
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
            // var employeeId = await LocalDBConfig().getUserId();
            // var userId = userData["employee_id"].toString();

            // if (!employeeId!.contains(userId)) {

            // }
            UserModel userModel = UserModel();
            userModel.userId = userData["employee_id"].toString();
            userModel.userName = userData["full_name"].toString();
            setState(() {
              userDataList.add(userModel);
            });
          }

          for (var data in resultData["head"]["msg"]["task_month_year"]) {
            setState(() {
              taskMonthYearList.add(data);
            });
          }
        } else if (resultData["head"]["code"] == 400) {
          setState(() {
            companyDataList.clear();
            departmentDataList.clear();
            userDataList.clear();
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appbar(context),
        bottomNavigationBar: bottomaAppbar(context),
        body: FutureBuilder(
            future: formDataHandler,
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
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    child: Column(
                      children: [
                        Column(
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
                                      .firstWhere((company) =>
                                          company.companyId ==
                                          selectedCompanyId)
                                      .companyName
                                  : null,
                              items: companyDataList
                                  .map((company) => company.companyName!)
                                  .toList(),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: Colors.grey.shade200,
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
                                  var companyId = companyDataList
                                      .firstWhere((company) =>
                                          company.companyName == value)
                                      .companyId;
                                  companyOnChange(companyId);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
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
                                          department.departmentId ==
                                          selectedDepartmentId)
                                      .departmentName
                                  : null,
                              items: departmentDataList
                                  .where((department) =>
                                      department.companyId == selectedCompanyId)
                                  .map((department) =>
                                      department.departmentName!)
                                  .toList(),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: Colors.grey.shade200,
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
                                  var departmentId = departmentDataList
                                      .firstWhere((department) =>
                                          department.departmentName == value)
                                      .departmentId;
                                  departmentOnChange(departmentId);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Employee",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            CustomDropdown<String>.search(
                              hintText: 'Select user',
                              initialItem: selectedUserId != null
                                  ? userDataList
                                      .firstWhere((user) =>
                                          user.userId == selectedUserId)
                                      .userName
                                  : null,
                              items: userDataList
                                  .map((user) => user.userName!)
                                  .toList(),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: Colors.grey.shade200,
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
                                  userOnChange(userId);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Month",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            CustomDropdown<String>.search(
                              hintText: 'Select Priority',
                              items: taskMonthYearList
                                  .map((user) => user.toString())
                                  .toList(),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: Colors.grey.shade200,
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
                                  setState(() {
                                    selectedTaskMonthYear = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }

  companyOnChange(String? value) {
    setState(() {
      selectedDepartment = null;
      selectedDepartmentId = null;
      selectedCompanyId = value;
      selectedCompany = companyDataList
          .firstWhere(
            (company) => company.companyId == value,
            orElse: () => CompanyModel(),
          )
          .companyName;
    });
  }

  departmentOnChange(String? value) {
    setState(() {
      selectedDepartmentId = value;
      selectedDepartment = departmentDataList
          .firstWhere(
            (department) => department.departmentId == value,
            orElse: () => DepartmentModel(),
          )
          .departmentName;
    });
  }

  userOnChange(String? value) {
    setState(() {
      selectedUserId = value;
      selectedUser = userDataList
          .firstWhere(
            (user) => user.userId == value,
            orElse: () => UserModel(),
          )
          .userName;
    });
  }

  BottomAppBar bottomaAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Map formData = {
                "task_chart": 1,
                "entity_code": "",
                "department_id": "",
                "employee_id": "",
                "task_month_year": ""
              };

              if (selectedCompanyId != null) {
                formData["entity_code"] = selectedCompanyId;
              }

              if (selectedDepartmentId != null) {
                formData["department_id"] = selectedDepartmentId;
              }

              if (selectedUserId != null) {
                formData["employee_id"] = selectedUserId;
              }

              if (selectedTaskMonthYear != null) {
                formData["task_month_year"] = selectedTaskMonthYear;
              }

              Navigator.pop(context, formData);
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
                      "Apply",
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
                Navigator.pop(context, null);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        "Pie Chart Filter",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
