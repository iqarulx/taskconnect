/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '/services/http/http_config.dart';
import '/view/utils/assets.dart';
import '/view/utils/colors.dart';
import '/view/utils/error_display.dart';
import '/view/utils/loading.dart';
import 'package:http/http.dart' as http;
import '/view/utils/snackbar.dart';
import '../dashboard/helper.dart'
    if (dart.library.html) 'helper/save_file_web.dart' as helper;

class FilePreview extends StatefulWidget {
  final File? file;
  final String? networkFile;

  const FilePreview({super.key, required this.file, required this.networkFile});

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
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
            title: Text(
              "File Preview",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.black,
                  ),
            ),
          ),
          body: FutureBuilder<String>(
            future: domainHandler,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return futureWaitingLoading();
              } else if (snapshot.hasError) {
                return futureDisplayError(content: snapshot.error.toString());
              } else if (snapshot.hasData) {
                String domain = snapshot.data!;
                return body(domain);
              } else {
                return futureDisplayError(content: 'Unknown error');
              }
            },
          )),
    );
  }

  Widget body(String domain) {
    if (widget.file != null) {
      String fileExtension = widget.file!.path.split('.').last.toLowerCase();

      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png') {
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 3,
                      child: Image.file(widget.file!, fit: BoxFit.fill)),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.file!.path.split('/').last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ));
      } else if (fileExtension == 'pdf') {
        return SfPdfViewer.file(widget.file!);
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(LottieAssets.preview, height: 150, width: 150),
              Text(
                "No preview available for \n ${widget.file!.path.split('/').last}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              // GestureDetector(
              //   onTap: () {
              //     openLocalFile(widget.file!);
              //   },
              //   child: Container(
              //     height: 48,
              //     width: 200,
              //     decoration: BoxDecoration(
              //       color: greenColor,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Center(
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(
              //             Iconsax.document_download,
              //             color: Colors.white,
              //           ),
              //           const SizedBox(
              //             width: 10,
              //           ),
              //           Text(
              //             "View File",
              //             style:
              //                 Theme.of(context).textTheme.bodyLarge!.copyWith(
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.w500,
              //                     ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      }
    } else {
      String fileUrl = '$domain${widget.networkFile!}';
      String fileExtension = widget.networkFile!.split('.').last.toLowerCase();

      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png') {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white12),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Image.network(fileUrl, fit: BoxFit.fill)),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.networkFile!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );
      } else if (fileExtension == 'pdf') {
        return SfPdfViewer.network(fileUrl);
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(LottieAssets.preview, height: 150, width: 150),
              Text(
                "No preview available for \n ${widget.networkFile!}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  downloadFile(fileUrl);
                },
                child: Container(
                  height: 48,
                  width: 200,
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.document_download,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Download File",
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
        );
      }
    }
  }

  Future<String>? domainHandler;
  String? domain;

  Future<String> getDomain() async {
    try {
      String? domain = await HttpConfig().getFiledomain();
      setState(() {
        this.domain = domain;
      });
      return domain!;
    } catch (e) {
      throw 'Failed to fetch domain';
    }
  }

  @override
  void initState() {
    domainHandler = getDomain();
    super.initState();
  }

  downloadFile(fileUrl) async {
    futureLoading(context);
    var fileName = fileUrl.split('/').last;
    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      Navigator.pop(context);
      await helper.saveAndLaunchFile(bytes, fileName);
    } else {
      Navigator.pop(context);
      showSnackBar(context,
          content: "Failed to download file", isSuccess: false);
    }
  }
}
