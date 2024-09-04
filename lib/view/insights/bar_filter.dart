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

class BarFilter extends StatefulWidget {
  const BarFilter({super.key});

  @override
  State<BarFilter> createState() => _BarFilterState();
}

class _BarFilterState extends State<BarFilter> {
  List<UserModel> userDataList = [];
  Future? formDataHandler;
  String? selectedUserId;
  String? selectedUser;

  @override
  void initState() {
    formDataHandler = getForm();
    super.initState();
  }

  Future getForm() async {
    try {
      setState(() {
        userDataList.clear();
      });

      return await InsightsService()
          .getChartData(formData: {"bar_chart": 1}).then((resultData) async {
        if (resultData.isNotEmpty && resultData["head"]["code"] == 200) {
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
        } else if (resultData["head"]["code"] == 400) {
          setState(() {
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                    .firstWhere(
                                        (user) => user.userId == selectedUserId)
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
                                employeeOnChange(userId);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  employeeOnChange(String? value) {
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
                "bar_chart": 1,
                "employee_id": "",
              };

              if (selectedUserId != null) {
                formData["employee_id"] = selectedUserId;
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
        "Bar Chart Filter",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
