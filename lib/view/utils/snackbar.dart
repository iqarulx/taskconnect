/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import '/view/utils/colors.dart';

void showSnackBar(BuildContext context,
    {required String content, required bool isSuccess}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Iconsax.tick_circle : Iconsax.close_circle,
            color: Colors.white,
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Text(
              content,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ),
  );
}

showSnackBarOption(context,
    {required String content,
    required bool isSuccess,
    required String redirect}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Iconsax.tick_circle : Iconsax.close_circle,
              color: Colors.white,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(content),
          ],
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: isSuccess ? Colors.green : redColor,
        action: SnackBarAction(
          label: "View",
          textColor: Colors.white,
          onPressed: () async {
            OpenFile.open(redirect);
          },
        )),
  );
}
