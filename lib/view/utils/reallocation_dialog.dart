/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import '/models/dashboard_model.dart';
import '/services/http/dashboard_service.dart';
import '/view/utils/colors.dart';
import '/view/utils/loading.dart';
import '/view/utils/snackbar.dart';

class ReallocationDialog extends StatefulWidget {
  final String taskId;
  const ReallocationDialog({super.key, required this.taskId});

  @override
  State<ReallocationDialog> createState() => _ReallocationDialogState();
}

class _ReallocationDialogState extends State<ReallocationDialog> {
  Future<void>? reallocateUserHandler;
  List<ReallocateUserModel> userList = [];
  String? selectedUser;
  String? selectedUserId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> userListView() async {
    try {
      setState(() {
        userList.clear();
      });

      await DashboardService()
          .getReallocateUser(widget.taskId)
          .then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var data in resultData["head"]["msg"]) {
            ReallocateUserModel model = ReallocateUserModel();
            model.employeeId = data["employee_id"].toString();
            model.employeeName = data["employee_name"].toString();
            setState(() {
              userList.add(model);
            });
          }
        } else if (resultData["head"]["code"] == 400) {
          setState(() {
            userList.clear();
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
  void initState() {
    reallocateUserHandler = userListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const Text("Reallocate Task"),
      content: const Text("Are you sure want to reallocate task?"),
      actions: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Reallocate To",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder(
                future: reallocateUserHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureWaitingLoading();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return CustomDropdown<String>.search(
                      hintText: 'Select user',
                      initialItem: selectedUserId != null
                          ? userList
                              .firstWhere(
                                  (user) => user.employeeId == selectedUserId)
                              .employeeName
                          : null,
                      items:
                          userList.map((user) => user.employeeName!).toList(),
                      decoration: CustomDropdownDecoration(
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
                          var userId = userList
                              .firstWhere((user) => user.employeeName == value)
                              .employeeId;
                          setState(() {
                            selectedUserId = userId;
                          });
                        }
                      },
                    );
                    // DropdownButtonFormField<String>(
                    //   menuMaxHeight: 300,
                    //   value: selectedUserId,
                    //   dropdownColor: Colors.white,
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       selectedUserId = newValue;
                    //       selectedUser = userList
                    //           .firstWhere(
                    //             (user) => user.employeeId == newValue,
                    //             orElse: () => ReallocateUserModel(),
                    //           )
                    //           .employeeName;
                    //     });
                    //   },
                    //   decoration: InputDecoration(
                    //     labelText: 'User',
                    //     enabledBorder: OutlineInputBorder(
                    //       borderSide: BorderSide(
                    //         color: Colors.grey.shade300,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(
                    //         color: Colors.grey.shade300,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide: const BorderSide(
                    //         color: greenColor,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //   ),
                    //   items: userList
                    //       .map((user) => DropdownMenuItem(
                    //             value: user.employeeId,
                    //             child: Text(user.employeeName!),
                    //           ))
                    //       .toList(),
                    //   validator: (value) {
                    //     if (value == null) {
                    //       return 'Please select employee';
                    //     }
                    //     return null;
                    //   },
                    // );
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: whiteColor,
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: greyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          if (selectedUserId != null) {
                            futureLoading(context);
                            DashboardService()
                                .reallocateTask(widget.taskId, selectedUserId!)
                                .then((onValue) {
                              Navigator.pop(context);

                              if (onValue["head"]["code"] == 200) {
                                Navigator.pop(context, true);
                              }
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: greenColor,
                        ),
                        child: const Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
