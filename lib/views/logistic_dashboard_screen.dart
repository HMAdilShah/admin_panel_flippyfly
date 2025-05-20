import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:webkit/controller/logistic_dashboard_controller.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_flex.dart';
import 'package:webkit/helpers/widgets/my_flex_item.dart';
import 'package:webkit/helpers/widgets/my_progress_bar.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/views/layouts/layout.dart';
import 'package:webkit/helpers/extensions/string.dart';

class LogisticDashboardScreen extends StatefulWidget {
  const LogisticDashboardScreen({super.key});

  @override
  State<LogisticDashboardScreen> createState() => _LogisticDashboardScreenState();
}

class _LogisticDashboardScreenState extends State<LogisticDashboardScreen> with SingleTickerProviderStateMixin, UIMixin {
  late LogisticDashboardController controller;

  @override
  void initState() {
    controller = Get.put(LogisticDashboardController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'logistic_dashboard_controller',
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "logistic".tr(),
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'dashboard'.tr(), active: true),
                        MyBreadcrumbItem(name: 'logistic'.tr()),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: MyFlex(
                  children: [
                    MyFlexItem(child: orderCard()),
                    MyFlexItem(
                      sizes: 'lg-8 md-6 sm-12',
                      child: MyCard(
                        shadow: MyShadow(elevation: .5),
                        padding: MySpacing.fromLTRB(24, 24, 24, 8),
                        borderRadiusAll: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.titleMedium("Analytics View", fontWeight: 600),
                            MySpacing.height(20),
                            analyticsViewChart(),
                          ],
                        ),
                      ),
                    ),
                    MyFlexItem(
                      sizes: 'lg-4 md-6 sm-12',
                      child: MyCard(
                        borderRadiusAll: 8,
                        padding: MySpacing.fromLTRB(24, 24, 24, 8),
                        shadow: MyShadow(elevation: .5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText.titleMedium("Cash flow State", fontWeight: 600),
                                MyContainer.rounded(
                                  color: contentTheme.primary,
                                  paddingAll: 4,
                                  child: Icon(LucideIcons.download, size: 16, color: contentTheme.onPrimary),
                                )
                              ],
                            ),
                            MySpacing.height(20),
                            cashFlowStateChart(),
                          ],
                        ),
                      ),
                    ),
                    MyFlexItem(sizes: 'lg-4 sm-12', child: whereHouseOperatingCost()),
                    MyFlexItem(sizes: 'lg-4 sm-12', child: map()),
                    MyFlexItem(sizes: 'lg-4 sm-12', child: deliveriesByCountry()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget map() {
    return MyCard(
      shadow: MyShadow(elevation: .5),
      borderRadiusAll: 8,
      child: SizedBox(
        height: 410,
        child: SfMaps(
          layers: [
            MapShapeLayer(
                source: controller.dataSource,
                sublayers: [
                  MapPolylineLayer(
                    polylines: List<MapPolyline>.generate(controller.polyLines.length, (int index) {
                      PolylineModel polyLine = controller.polyLines[index];
                      bool isSelect = controller.selectedIndex == index;
                      return MapPolyline(
                          points: polyLine.points, color: isSelect ? Colors.pink : Colors.blue, onTap: () => controller.isSelectIndex(index));
                    }).toSet(),
                  )
                ],
                zoomPanBehavior: controller.zoomPanBehavior),
          ],
        ),
      ),
    );
  }

  Widget deliveriesByCountry() {
    Widget countryDetail(String countryName, percentage, double progress, Color color) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium(countryName, fontWeight: 600),
              MyText.bodySmall('$percentage%', fontWeight: 600),
            ],
          ),
          MySpacing.height(8),
          MyProgressBar(width: 500, height: 8, inactiveColor: contentTheme.title.withAlpha(36), progress: progress, activeColor: color),
        ],
      );
    }

    return MyCard(
      shadow: MyShadow(elevation: .5),
      borderRadiusAll: 8,
      paddingAll: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium("Deliveries by Country", fontWeight: 600),
              MyContainer(
                paddingAll: 4,
                color: contentTheme.primary.withAlpha(36),
                child: Icon(LucideIcons.trending_up, size: 16, color: contentTheme.primary),
              )
            ],
          ),
          MySpacing.height(24),
          countryDetail("Australia", "12", .5, contentTheme.primary),
          MySpacing.height(24),
          countryDetail("Brazil", "65", .6, contentTheme.info),
          MySpacing.height(24),
          countryDetail("Germany", "78", .7, contentTheme.success),
          MySpacing.height(24),
          countryDetail("Denmark", "53", .5, contentTheme.warning),
          MySpacing.height(24),
          countryDetail("France", "70", .7, contentTheme.danger),
          MySpacing.height(24),
          countryDetail("Canada", "80", .8, contentTheme.primary),
        ],
      ),
    );
  }

  Widget whereHouseOperatingCost() {
    Widget detail(String title, costValue, order, daysTime, IconData icon) {
      return Padding(
        padding: MySpacing.x(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(title, fontWeight: 600),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: icon == LucideIcons.arrow_up ? contentTheme.primary : contentTheme.danger),
                    MySpacing.width(4),
                    MyText.bodyMedium('$costValue last month'),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText.bodyMedium(order, fontWeight: 600),
                MyText.bodySmall("$daysTime days ago", fontWeight: 600),
              ],
            ),
          ],
        ),
      );
    }

    return MyCard(
      shadow: MyShadow(elevation: .5),
      borderRadiusAll: 8,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.nBottom(24), child: MyText.titleMedium("Warehouse Operating Costs", fontWeight: 600)),
          MySpacing.height(20),
          detail("Order Packing", "3%", "1948", '10', LucideIcons.arrow_up),
          Divider(height: 36),
          detail("Storage", "14%", "2932", '5', LucideIcons.arrow_down),
          Divider(height: 36),
          detail("Shipping", "05%", "2738", '5', LucideIcons.arrow_up),
          Divider(height: 36),
          detail("Receiving", "8%", "3894", '3', LucideIcons.arrow_up),
          Divider(height: 36),
          detail("Other", "9%", "923", '15', LucideIcons.arrow_down),
          MySpacing.height(20),
        ],
      ),
    );
  }

  SfCartesianChart analyticsViewChart() {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
        primaryXAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift, majorGridLines: MajorGridLines(width: 0), interval: 2),
        primaryYAxis: NumericAxis(
            minimum: 3,
            maximum: 21,
            interval: 3,
            labelFormat: '{value}%',
            axisLine: AxisLine(width: 0),
            majorTickLines: MajorTickLines(color: Colors.transparent)),
        series: controller.analyticsChart(),
        tooltipBehavior: TooltipBehavior(enable: true));
  }

  SfCartesianChart cashFlowStateChart() {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(maximum: 20, minimum: 0, interval: 4, axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0)),
        series: controller.getDefaultColumn(),
        legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            alignment: ChartAlignment.center,
            height: "10%",
            orientation: LegendItemOrientation.horizontal),
        tooltipBehavior: controller.columnToolTip);
  }

  MyFlex orderCard() {
    return MyFlex(contentPadding: false, children: [
      orderCardsDetail("28", "EK-34389", 'Anna'),
      orderCardsDetail("29", "AM-72538", 'Deirdre'),
      orderCardsDetail("95", "DJ-04853", 'Kimberly'),
      orderCardsDetail("20", "DU-32278", 'Samantha'),
      MyFlexItem(
        sizes: 'lg-2.4 xl-2.4 md-8 sm-8',
        child: MyCard(
          shadow: MyShadow(elevation: .5),
          borderRadiusAll: 8,
          paddingAll: 24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyText.bodyMedium("Quick Link", fontWeight: 600, height: .6, overflow: TextOverflow.ellipsis),
                  ),
                  InkWell(
                    onTap: () {},
                    child: MyText.bodySmall("View All", height: .6, fontWeight: 600, color: contentTheme.secondary),
                  ),
                ],
              ),
              MySpacing.height(20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyContainer(
                          width: double.infinity,
                          color: contentTheme.secondary.withAlpha(36),
                          child: Icon(LucideIcons.users, size: 31, color: contentTheme.secondary),
                        ),
                        MySpacing.height(8),
                        MyText.bodyMedium("Driver List", fontWeight: 600, overflow: TextOverflow.ellipsis, maxLines: 1)
                      ],
                    ),
                  ),
                  MySpacing.width(24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyContainer(
                          width: double.infinity,
                          color: contentTheme.secondary.withAlpha(36),
                          child: Icon(LucideIcons.chart_bar, size: 31, color: contentTheme.secondary),
                        ),
                        MySpacing.height(8),
                        MyText.bodyMedium("Expanse Table", fontWeight: 600, overflow: TextOverflow.ellipsis, maxLines: 1)
                      ],
                    ),
                  ),
                ],
              ),
              MySpacing.height(24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyContainer(
                          width: double.infinity,
                          color: contentTheme.secondary.withAlpha(36),
                          child: Icon(LucideIcons.map_pin, size: 31, color: contentTheme.secondary),
                        ),
                        MySpacing.height(8),
                        MyText.bodyMedium("Route List", fontWeight: 600, overflow: TextOverflow.ellipsis, maxLines: 1)
                      ],
                    ),
                  ),
                  MySpacing.width(24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyContainer(
                          width: double.infinity,
                          color: contentTheme.secondary.withAlpha(36),
                          child: Icon(LucideIcons.chart_pie, size: 31, color: contentTheme.secondary),
                        ),
                        MySpacing.height(8),
                        MyText.bodyMedium("Analytics", fontWeight: 600, overflow: TextOverflow.ellipsis, maxLines: 1)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  MyFlexItem orderCardsDetail(String km, shipmentNumber, driverName) {
    return MyFlexItem(
        sizes: 'lg-2.4 xl-2.4 md-4 sm-4',
        child: MyCard(
          shadow: MyShadow(elevation: .5),
          paddingAll: 24,
          borderRadiusAll: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodySmall("KM Remains", fontWeight: 600, overflow: TextOverflow.ellipsis),
                        MyText.bodyMedium("$km KM", fontWeight: 600, color: contentTheme.primary, overflow: TextOverflow.ellipsis)
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyText.bodySmall("Status", fontWeight: 600, overflow: TextOverflow.ellipsis),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyContainer.rounded(paddingAll: 4, color: contentTheme.success),
                          MySpacing.width(4),
                          MyText.bodyMedium("Active", fontWeight: 600, overflow: TextOverflow.ellipsis),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              MySpacing.height(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MyContainer.rounded(
                              paddingAll: 8,
                              color: contentTheme.success.withAlpha(36),
                              child: Icon(LucideIcons.arrow_up_right, size: 16, color: contentTheme.success),
                            ),
                            MySpacing.width(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.bodyMedium("Athens GRC", fontWeight: 600, overflow: TextOverflow.ellipsis),
                                  MyText.bodySmall("Pickup Zone", overflow: TextOverflow.ellipsis, fontWeight: 600, muted: true),
                                ],
                              ),
                            )
                          ],
                        ),
                        MySpacing.height(20),
                        Row(
                          children: [
                            MyContainer.rounded(
                              paddingAll: 8,
                              color: contentTheme.primary.withAlpha(36),
                              child: Icon(LucideIcons.arrow_down_right, size: 16, color: contentTheme.primary),
                            ),
                            MySpacing.width(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.bodyMedium("Taimar, Est", fontWeight: 600, overflow: TextOverflow.ellipsis),
                                  MyText.bodySmall("Near Controller Motel", fontWeight: 600, muted: true, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Icon(LucideIcons.truck, size: 28, color: contentTheme.secondary)
                ],
              ),
              Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodySmall("Shipment Number", fontWeight: 600, overflow: TextOverflow.ellipsis),
                        MyText.bodyMedium(shipmentNumber, fontWeight: 600, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText.bodySmall("Driver", fontWeight: 600, overflow: TextOverflow.ellipsis),
                        MyText.bodyMedium(driverName, fontWeight: 600, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
