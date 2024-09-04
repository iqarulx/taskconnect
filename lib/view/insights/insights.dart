/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '/models/insights_model.dart';
import '/services/http/insights_service.dart';
import '/services/local_db/local_db.dart';
import '/view/insights/bar_filter.dart';
import '/view/insights/pie_filter.dart';
import '/view/utils/colors.dart';
import '/view/utils/error_display.dart';
import '/view/utils/loading.dart';
import '/view/utils/snackbar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/view/utils/widget_utils.dart';

class InsightsView extends StatefulWidget {
  const InsightsView({super.key});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  String name = "", email = "";
  List<ChartDataModel> chartDataList = [];
  List<BarDataModel> barChartDataList = [];

  Future? chartDataHandler;
  Future? barChartDataHandler;
  List<Chart1PieModel> chart1Data = [];
  List<Chart2PieModel> chart2Data = [];
  List<Chart3BarModel> chart3Data = [];

  @override
  void initState() {
    chartDataHandler = getChart({"task_chart": 1}).whenComplete(initPieChart);
    barChartDataHandler =
        getBarChart({"bar_chart": 1}).whenComplete(initBarChart);
    super.initState();
  }

  initPieChart() {
    chart1Data.clear();
    for (var data in chartDataList.first.chart1) {
      chart1Data.add(
        Chart1PieModel(
          data["name"]!,
          data["y"] > 0 ? data["y"] : 0,
          data["name"] == "Completed"
              ? greenCardColor
              : data["name"] == "Pending"
                  ? yellowCardColor
                  : data["name"] == "In Progress"
                      ? blueGraphColor
                      : data["name"] == "Cancelled"
                          ? blackGraphColor
                          : data["name"] == "Rejected"
                              ? redGraphColor
                              : blackColor,
        ),
      );
    }

    chart2Data.clear();
    for (var data in chartDataList.first.chart2) {
      chart2Data.add(Chart2PieModel(
          data["name"]!,
          data["y"] > 0 ? data["y"] : 0,
          data["name"] == "Completed" ? greenCardColor : yellowCardColor));
    }
  }

  initBarChart() {
    chart3Data.clear();
    for (var i = 0; i < barChartDataList.first.chart3["yaxis"].length; i++) {
      var yaxis = barChartDataList.first.chart3["yaxis"][i];
      var data = barChartDataList.first.chart3["arrData"];
      for (var item in data) {
        Color color;
        switch (item["name"]) {
          case "Task completed":
            color = greenCardColor;
            break;
          case "Pending":
            color = yellowCardColor;
            break;
          case "Inprogress":
            color = blueGraphColor;
            break;
          case "Cancelled":
            color = blackGraphColor;
            break;
          case "Rejected":
            color = redGraphColor;
            break;
          default:
            color = blackColor;
        }

        chart3Data.add(Chart3BarModel(
          yaxis,
          item["data"][i],
          color,
        ));
      }
    }
  }

  Future getChart(formData) async {
    try {
      setState(() {
        chartDataList.clear();
      });

      return await InsightsService()
          .getChartData(formData: formData)
          .then((resultData) async {
        if (resultData.isNotEmpty && resultData["head"]["code"] == 200) {
          var data = resultData["head"]["msg"];
          ChartDataModel chartDataModel = ChartDataModel();
          chartDataModel.chart1 = data["chart_1"];
          chartDataModel.chart2 = data["chart_2"];
          chartDataModel.chart3 = data["chart_3"];
          chartDataModel.pendingCount = data["pending_count"].toString();
          chartDataModel.completedCount = data["completed_count"].toString();
          chartDataModel.progressCount = data["in_progress_count"].toString();

          setState(() {
            chartDataList.add(chartDataModel);
          });
        } else if (resultData["head"]["code"] == 400) {
          setState(() {
            chartDataList.clear();
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

  Future getBarChart(formData) async {
    try {
      setState(() {
        barChartDataList.clear();
      });

      return await InsightsService()
          .getChartData(formData: formData)
          .then((resultData) async {
        if (resultData.isNotEmpty && resultData["head"]["code"] == 200) {
          var data = resultData["head"]["msg"];
          BarDataModel barDataModel = BarDataModel();

          barDataModel.chart3 = data["chart_3"];

          setState(() {
            barChartDataList.add(barDataModel);
          });
        } else if (resultData["head"]["code"] == 400) {
          setState(() {
            barChartDataList.clear();
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

  getEmployee() async {
    name = await LocalDBConfig().getName() ?? '';
    email = await LocalDBConfig().getEmail() ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appbar(),
          body: TabBarView(controller: _tabController, children: [
            FutureBuilder(
                future: chartDataHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureWaitingLoading();
                  } else if (snapshot.hasError) {
                    if (snapshot.error == 'Network Error') {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    } else {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Widgets().cardContainer(
                                      chartDataList.first.progressCount ??
                                          0.toString(),
                                      "In Progress",
                                      yellowCardColor)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Widgets().cardContainer(
                                      chartDataList.first.completedCount ??
                                          0.toString(),
                                      "Completed",
                                      yellowCardColor)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: GestureDetector(
                                    onTap: () {},
                                    child: Widgets().cardContainer(
                                        chartDataList.first.pendingCount ??
                                            0.toString(),
                                        "Pending",
                                        yellowCardColor)))
                          ],
                        ),
                        chart1View(),
                        chart2View()
                      ]),
                    );
                  }
                }),
            FutureBuilder(
                future: barChartDataHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureWaitingLoading();
                  } else if (snapshot.hasError) {
                    if (snapshot.error == 'Network Error') {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    } else {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    }
                  } else {
                    return chart3View();
                  }
                }),
          ]),
          floatingActionButton: floatingButtons()),
    );
  }

  Column chart3View() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              String text;
              switch (chart3Data[index].color) {
                case greenCardColor:
                  text = "Task completed";
                  break;
                case yellowCardColor:
                  text = "Pending";
                  break;
                case blueGraphColor:
                  text = "Inprogress";
                  break;
                case blackGraphColor:
                  text = "Cancelled";
                  break;
                case redGraphColor:
                  text = "Rejected";
                  break;
                default:
                  text = "";
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: chart3Data[index].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(text),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: SfCartesianChart(
            backgroundColor: Colors.white,
            enableSideBySideSeriesPlacement: true,
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: const NumericAxis(),
            series: <CartesianSeries>[
              for (var data in chart3Data)
                BarSeries<Chart3BarModel, String>(
                  trackColor: Colors.black,
                  enableTooltip: true,
                  dataSource: [data],
                  xValueMapper: (Chart3BarModel tasks, _) => tasks.yaxis,
                  yValueMapper: (Chart3BarModel tasks, _) =>
                      tasks.xaxis.toDouble(),
                  dataLabelMapper: (Chart3BarModel tasks, _) =>
                      tasks.xaxis.toString(),
                  pointColorMapper: (Chart3BarModel tasks, _) => tasks.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    alignment: ChartAlignment.center,
                  ),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  SfCircularChart chart1View() {
    return SfCircularChart(
        legend: const Legend(isVisible: true),
        backgroundColor: pureWhiteColor,
        series: <PieSeries<Chart1PieModel, String>>[
          PieSeries<Chart1PieModel, String>(
            enableTooltip: true,
            explode: true,
            explodeIndex: null,
            dataSource: chart1Data,
            xValueMapper: (Chart1PieModel data, _) => data.xData,
            yValueMapper: (Chart1PieModel data, _) => data.yData,
            dataLabelMapper: (Chart1PieModel data, _) =>
                "${data.yData.toString()} - ${data.xData}",
            pointColorMapper: (Chart1PieModel data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                // color: pureWhiteColor,
                labelPosition: ChartDataLabelPosition.outside),
          ),
        ]);
  }

  SfCircularChart chart2View() {
    return SfCircularChart(
        backgroundColor: pureWhiteColor,
        legend: const Legend(isVisible: true),
        series: <PieSeries<Chart2PieModel, String>>[
          PieSeries<Chart2PieModel, String>(
            enableTooltip: true,
            explode: true,
            explodeIndex: null,
            dataSource: chart2Data,
            xValueMapper: (Chart2PieModel data, _) => data.xData,
            yValueMapper: (Chart2PieModel data, _) => data.yData,
            pointColorMapper: (Chart2PieModel data, _) => data.color,
            dataLabelMapper: (Chart2PieModel data, _) =>
                "${data.yData.toString()} - ${data.xData}",
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                // color: pureWhiteColor,
                labelPosition: ChartDataLabelPosition.outside),
          ),
        ]);
  }

  Column floatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: null,
          foregroundColor: whiteColor,
          backgroundColor: greenColor,
          shape: const CircleBorder(),
          onPressed: () {
            openPieFilter();
          },
          child: const Icon(Iconsax.graph),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          heroTag: null,
          foregroundColor: whiteColor,
          backgroundColor: greenColor,
          shape: const CircleBorder(),
          onPressed: () {
            openBarFilter();
          },
          child: const Icon(Iconsax.chart_1),
        ),
      ],
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: whiteColor),
      backgroundColor: greenColor,
      title: const Text(
        "Insights",
        style: TextStyle(color: whiteColor),
      ),
      bottom: TabBar(
        labelColor: whiteColor,
        indicatorColor: whiteColor,
        unselectedLabelColor: whiteColor,
        controller: _tabController,
        tabs: const [
          Tab(
            text: "Pie Chart",
          ),
          Tab(
            text: "Bar Chart",
          ),
        ],
      ),
    );
  }

  openPieFilter() async {
    await showModalBottomSheet(
      backgroundColor: whiteColor,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const PieFilter();
      },
    ).then((onValue) {
      if (onValue != null) {
        setState(() {
          chartDataHandler = getChart(onValue).whenComplete(initPieChart);
        });
      }
    });
  }

  openBarFilter() async {
    await showModalBottomSheet(
      backgroundColor: whiteColor,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const BarFilter();
      },
    ).then((onValue) {
      if (onValue != null) {
        setState(() {
          barChartDataHandler = getBarChart(onValue).whenComplete(initBarChart);
        });
      }
    });
  }
}
