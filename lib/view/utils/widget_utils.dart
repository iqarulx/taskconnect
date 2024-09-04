/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';

class Widgets {
  Widget cardContainer(String count, String text, Color color) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
            ),
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget floatingActionButton(Color color, VoidCallback onPressed, Icon icon) {
    return FloatingActionButton(
      foregroundColor: Colors.white,
      backgroundColor: color,
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: icon,
    );
  }
}
