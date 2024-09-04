import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/providers/file_picker.dart';
import '/services/http/dashboard_service.dart';
import '/view/utils/assets.dart';
import '/view/utils/colors.dart';
import '/view/utils/loading.dart';

class TaskcompleteDialog extends StatefulWidget {
  final String taskId;
  const TaskcompleteDialog({super.key, required this.taskId});

  @override
  State<TaskcompleteDialog> createState() => _TaskcompleteDialogState();
}

class _TaskcompleteDialogState extends State<TaskcompleteDialog> {
  File? file;

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
      title: const Text("Task Completion"),
      content: const Text("Are you sure want to complete task?"),
      actions: [
        Row(
          children: [
            const Text(
              "Attachment",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextFormField(
                onTap: () {
                  FilePickerService().pickFile(context).then((onValue) {
                    setState(() {
                      file = onValue;
                    });
                  });
                },
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
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        file != null
            ? Stack(children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(
                            Iconsax.close_circle,
                            size: 25,
                          ),
                          onPressed: () {
                            setState(() {
                              file = null;
                            });
                          },
                        ),
                      ),
                      Image.asset(
                        DecorationAssets.file,
                        height: 100,
                        width: 100,
                      ),
                      Text(file!.path.split('/').last),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ])
            : Container(),
        const SizedBox(
          height: 10,
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
                  if (file != null) {
                    futureLoading(context);
                    FilePickerService()
                        .uploadFile(file, 'recepient', 0)
                        .then((onValue) async {
                      Navigator.pop(context);
                      await DashboardService()
                          .completeTask(widget.taskId, onValue)
                          .then((onValue) {
                        if (onValue["head"]["code"] == 200) {
                          Navigator.pop(context, true);
                        } else {
                          Navigator.pop(context, false);
                        }
                      });
                    });
                  } else {
                    futureLoading(context);
                    await DashboardService()
                        .completeTask(widget.taskId, '')
                        .then((onValue) {
                      Navigator.pop(context);
                      if (onValue["head"]["code"] == 200) {
                        Navigator.pop(context, true);
                      } else {
                        Navigator.pop(context, false);
                      }
                    });
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
    );
  }
}
