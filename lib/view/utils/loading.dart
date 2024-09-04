/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/view/utils/assets.dart';
import '/view/utils/colors.dart';

futureLoading(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            color: greenColor,
          ),
        ),
      ),
    ),
  );
}

futureFileUploadLoading(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child:
                Lottie.asset(LottieAssets.fileUpload, height: 200, width: 200)),
      ),
    ),
  );
}

futureWaitingLoading() {
  return const Center(
    child: CircularProgressIndicator(
      color: greenColor,
    ),
  );
}
