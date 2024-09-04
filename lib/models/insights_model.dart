/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';

class ChartDataModel {
  dynamic chart1, chart2, chart3;
  String? progressCount, completedCount, pendingCount;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["chart_1"] = chart1;
    mapping["chart_2"] = chart2;
    mapping["chart_3"] = chart3;
    mapping["progress_count"] = progressCount;
    mapping["completed_count"] = completedCount;
    mapping["pending_count"] = pendingCount;
  }
}

class BarDataModel {
  dynamic chart3;
  toMap() {
    var mapping = <String, dynamic>{};
    mapping["chart_3"] = chart3;
  }
}

class Chart1PieModel {
  Chart1PieModel(this.xData, this.yData, this.color, [this.text]);
  final String xData;
  final num yData;
  final Color color;
  String? text;
}

class Chart2PieModel {
  Chart2PieModel(this.xData, this.yData, this.color, [this.text]);
  final String xData;
  final num yData;
  final Color color;
  String? text;
}

class Chart3BarModel {
  Chart3BarModel(this.yaxis, this.xaxis, this.color);
  final String yaxis;
  final int xaxis;
  final Color color;
}
