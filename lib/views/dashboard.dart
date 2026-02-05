/*
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:webkit/controller/dashboard_controller.dart';
import 'package:webkit/helpers/extensions/string.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/theme/app_theme.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_dotted_line.dart';
import 'package:webkit/helpers/widgets/my_flex.dart';
import 'package:webkit/helpers/widgets/my_flex_item.dart';
import 'package:webkit/helpers/widgets/my_list_extension.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/my_text_style.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/images.dart';
import 'package:webkit/views/layouts/layout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin, UIMixin {
  late DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "dashboard".tr(),
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'dashboard'.tr(), active: true),
                        MyBreadcrumbItem(name: 'ecommerce'.tr()),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: MyFlex(
                  runAlignment: WrapAlignment.start,
                  wrapCrossAlignment: WrapCrossAlignment.start,
                  children: [
                    MyFlexItem(
                      child: MyFlex(
                        runAlignment: WrapAlignment.start,
                        wrapCrossAlignment: WrapCrossAlignment.start,
                        contentPadding: false,
                        children: [
                          // ===== FIRST COLUMN (4 CARDS) =====
                          MyFlexItem(
                            sizes: "lg-5",
                            child: MyFlex(
                              runAlignment: WrapAlignment.start,
                              wrapCrossAlignment: WrapCrossAlignment.start,
                              contentPadding: false,
                              children: [
                                MyFlexItem(
                                  sizes: "lg-6",
                                  child: buildCard(
                                    contentTheme.pink,
                                    LucideIcons.clock_4,
                                    "Reached",
                                    "\$152",
                                    LucideIcons.trending_up,
                                    contentTheme.success,
                                    "1.25",
                                    "Last Month",
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-6",
                                  child: buildCard(
                                    contentTheme.primary,
                                    LucideIcons.network,
                                    "Engaged",
                                    "\$50",
                                    LucideIcons.trending_down,
                                    contentTheme.red,
                                    "2.5",
                                    "Last Week",
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-6",
                                  child: buildCard(
                                    contentTheme.success,
                                    LucideIcons.chart_area,
                                    "Rich",
                                    "\$304",
                                    LucideIcons.trending_down,
                                    contentTheme.red,
                                    "1.23",
                                    "Last Month",
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-6",
                                  child: buildCard(
                                    contentTheme.warning,
                                    LucideIcons.shopping_cart,
                                    "Engagement",
                                    "\$189",
                                    LucideIcons.trending_up,
                                    contentTheme.success,
                                    "0.2",
                                    "Last Day",
                                  ),
                                ),
                              ],
                            ),
                          ),

                          MyFlexItem(
                            sizes: "lg-3",
                            child: MyFlex(
                              runAlignment: WrapAlignment.start,
                              wrapCrossAlignment: WrapCrossAlignment.start,
                              contentPadding: false,
                              children: [
                                MyFlexItem(
                                  sizes: "lg-12",
                                  child: buildCard(
                                    contentTheme.info,
                                    LucideIcons.trending_up,
                                    "Conversions",
                                    "\$420",
                                    LucideIcons.trending_up,
                                    contentTheme.success,
                                    "0.8",
                                    "This Week",
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-12",
                                  child: buildCard(
                                    contentTheme.secondary,
                                    LucideIcons.user_check,
                                    "Subscribers",
                                    "12.4k",
                                    LucideIcons.trending_down,
                                    contentTheme.red,
                                    "1.1",
                                    "Last Month",
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ===== SECOND COLUMN (CHART CARD) =====
                          MyFlexItem(
                            sizes: "lg-4",
                            child: MyCard(
                              shadow: MyShadow(elevation: 0.5),
                              height: 305,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              padding: MySpacing.only(left: 24, right: 12, top: 12),
                              color: contentTheme.dark,
                              child: Stack(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              MyText.titleMedium(
                                                "New Visitors",
                                                color: contentTheme.light,
                                                fontWeight: 600,
                                              ),
                                              MySpacing.width(8),
                                              MyContainer(
                                                padding: MySpacing.xy(12, 2),
                                                color: contentTheme.success,
                                                child: MyText.bodyMedium(
                                                  "Active",
                                                  fontSize: 12,
                                                  color: contentTheme.onSuccess,
                                                ),
                                              )
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              LucideIcons.move_right,
                                              size: 16,
                                              color: contentTheme.light,
                                            ),
                                          )
                                        ],
                                      ),
                                      MySpacing.height(16),
                                      Row(
                                        children: [
                                          MyDottedLine(
                                            height: 50,
                                            dottedLength: 1,
                                            color: Colors.grey.shade400,
                                            child: Padding(
                                              padding: MySpacing.xy(12, 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  MyText.bodyMedium(
                                                    "\$5,943",
                                                    fontSize: 20,
                                                    color: contentTheme.light,
                                                  ),
                                                  MySpacing.height(8),
                                                  MyText.bodyMedium(
                                                    "New Followers",
                                                    color: contentTheme.light,
                                                    fontWeight: 600,
                                                    muted: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          MySpacing.width(16),
                                          MyDottedLine(
                                            height: 50,
                                            dottedLength: 1,
                                            color: Colors.grey.shade400,
                                            child: Padding(
                                              padding: MySpacing.xy(12, 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  MyText.bodyMedium(
                                                    "150,000",
                                                    fontSize: 20,
                                                    color: contentTheme.light,
                                                  ),
                                                  MySpacing.height(8),
                                                  MyText.bodyMedium(
                                                    "Followers Goal",
                                                    color: contentTheme.light,
                                                    fontWeight: 600,
                                                    muted: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  MySpacing.height(16),
                                  Positioned(
                                    right: 0,
                                    left: 0,
                                    top: 100,
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      tooltipBehavior: controller.facebook,
                                      primaryXAxis: CategoryAxis(
                                        isVisible: false,
                                        majorGridLines: const MajorGridLines(width: 0),
                                        labelStyle: const TextStyle(fontSize: 0),
                                      ),
                                      primaryYAxis: NumericAxis(
                                        isVisible: false,
                                        labelStyle: const TextStyle(fontSize: 0),
                                        majorGridLines: const MajorGridLines(width: 0),
                                      ),
                                      series: [
                                        ColumnSeries<ChartSampleData, int>(
                                          width: 0.5,
                                          color: contentTheme.primary,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          dataSource: controller.facebookChart,
                                          xValueMapper: (ChartSampleData data, _) => data.x,
                                          yValueMapper: (ChartSampleData data, _) => data.y,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    MyFlexItem(
                      child: MyFlex(
                        runAlignment: WrapAlignment.start,
                        wrapCrossAlignment: WrapCrossAlignment.start,
                        contentPadding: false,
                        children: [
                          MyFlexItem(
                            sizes: "lg-8 xl-8",
                            child: MyCard(
                              shadow: MyShadow(elevation: 0.5),
                              paddingAll: 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: MySpacing.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: MyText.titleMedium(
                                            "Response time by location",
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: 600,
                                          ),
                                        ),
                                        PopupMenuButton(
                                          onSelected: controller.onSelectedTimeByLocation,
                                          itemBuilder: (BuildContext context) {
                                            return ["Year", "Month", "Week", "Day", "Hours"].map((behavior) {
                                              return PopupMenuItem(
                                                value: behavior,
                                                height: 32,
                                                child: MyText.bodySmall(
                                                  behavior.toString(),
                                                  color: theme.colorScheme.onSurface,
                                                  fontWeight: 600,
                                                ),
                                              );
                                            }).toList();
                                          },
                                          color: theme.cardTheme.color,
                                          child: MyContainer.bordered(
                                            padding: MySpacing.xy(12, 8),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                MyText.labelMedium(
                                                  controller.selectedTimeByLocation.toString(),
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                                Icon(
                                                  LucideIcons.chevron_down,
                                                  size: 22,
                                                  color: theme.colorScheme.onSurface,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  MySpacing.height(12),
                                  MyFlex(
                                    children: [
                                      MyFlexItem(
                                        sizes: "lg-3",
                                        child: buildResponseTimeByLocationData(
                                          "Current Week",
                                          "\$1859.52",
                                          LucideIcons.corner_right_up,
                                          contentTheme.success,
                                        ),
                                      ),
                                      MyFlexItem(
                                        sizes: "lg-3",
                                        child: buildResponseTimeByLocationData(
                                          "Previous Week",
                                          "\$1568",
                                          LucideIcons.corner_right_down,
                                          contentTheme.red,
                                        ),
                                      ),
                                      MyFlexItem(
                                        sizes: "lg-3",
                                        child: buildResponseTimeByLocationData(
                                          "Conversation",
                                          "5.68%",
                                          LucideIcons.corner_right_up,
                                          contentTheme.success,
                                        ),
                                      ),
                                      MyFlexItem(
                                        sizes: "lg-3",
                                        child: buildResponseTimeByLocationData(
                                          "Customers",
                                          "80K",
                                          LucideIcons.corner_right_up,
                                          contentTheme.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  MySpacing.height(12),
                                  const Divider(),
                                  Padding(
                                    padding: MySpacing.all(16),
                                    child: SfCartesianChart(
                                      primaryXAxis: CategoryAxis(),
                                      tooltipBehavior: controller.chart,
                                      axes: <ChartAxis>[
                                        NumericAxis(
                                            numberFormat: NumberFormat.compact(),
                                            majorGridLines: const MajorGridLines(width: 0),
                                            opposedPosition: true,
                                            name: 'yAxis1',
                                            interval: 1000,
                                            minimum: 0,
                                            maximum: 7000)
                                      ],
                                      series: [
                                        ColumnSeries<ChartSampleData, String>(
                                            animationDuration: 2000,
                                            width: 0.5,
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                            color: contentTheme.primary,
                                            dataSource: controller.chartData,
                                            xValueMapper: (ChartSampleData data, _) => data.x,
                                            yValueMapper: (ChartSampleData data, _) => data.y,
                                            name: 'Unit Sold'),
                                        LineSeries<ChartSampleData, String>(
                                            animationDuration: 4500,
                                            animationDelay: 2000,
                                            dataSource: controller.chartData,
                                            xValueMapper: (ChartSampleData data, _) => data.x,
                                            yValueMapper: (ChartSampleData data, _) => data.yValue,
                                            yAxisName: 'yAxis1',
                                            markerSettings: const MarkerSettings(isVisible: true),
                                            name: 'Total Transaction')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          MyFlexItem(
                              sizes: "lg-4",
                              child: MyCard(
                                shadow: MyShadow(elevation: 0.5),
                                paddingAll: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyText.titleMedium(
                                          "Cost BreakDown",
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: 600,
                                        ),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              LucideIcons.move_right,
                                              size: 20,
                                            ))
                                      ],
                                    ),
                                    SfCircularChart(
                                      tooltipBehavior: TooltipBehavior(enable: true),
                                      series: <CircularSeries>[
                                        DoughnutSeries<ChartSampleData, String>(
                                            radius: '80%',
                                            explode: true,
                                            explodeOffset: '10%',
                                            dataSource: controller.circleChart,
                                            pointColorMapper: (ChartSampleData data, _) => data.pointColor,
                                            xValueMapper: (ChartSampleData data, _) => data.x,
                                            yValueMapper: (ChartSampleData data, _) => data.y,
                                            dataLabelSettings: const DataLabelSettings(isVisible: true)),
                                      ],
                                    ),
                                    // MySpacing.height(12),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [MyText.titleMedium("Top Channel"), MyText.titleMedium("Value")],
                                        ),
                                        MySpacing.height(12),
                                        buildCircleChartData(const Color.fromRGBO(9, 0, 136, 1), "Salary", "\$41,458"),
                                        MySpacing.height(8),
                                        buildCircleChartData(const Color.fromRGBO(147, 0, 119, 1), "Bill", "\$48,125"),
                                        MySpacing.height(8),
                                        buildCircleChartData(const Color.fromRGBO(228, 0, 124, 1), "Marketing", "\$19,458"),
                                        MySpacing.height(8),
                                        buildCircleChartData(const Color.fromRGBO(255, 189, 57, 1), "Other", "\$10,589"),
                                      ],
                                    )
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                    MyFlexItem(
                      child: MyFlex(
                        contentPadding: false,
                        children: [
                          MyFlexItem(
                            sizes: "lg-6",
                            child: MyCard(
                              shadow: MyShadow(elevation: 0.5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText.titleMedium(
                                        "High Value Design",
                                        fontWeight: 600,
                                      ),
                                      Row(
                                        children: [
                                          PopupMenuButton(
                                            onSelected: controller.onSelectedTimeDesign,
                                            itemBuilder: (BuildContext context) {
                                              return [
                                                "Year",
                                                "Month",
                                                "Week",
                                                "Day",
                                                "Hours",
                                              ].map((behavior) {
                                                return PopupMenuItem(
                                                  value: behavior,
                                                  height: 32,
                                                  child: MyText.bodySmall(
                                                    behavior.toString(),
                                                    color: theme.colorScheme.onSurface,
                                                    fontWeight: 600,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                            color: theme.cardTheme.color,
                                            child: MyContainer.bordered(
                                              padding: MySpacing.xy(12, 8),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  MyText.labelMedium(
                                                    controller.selectedTimeDesign.toString(),
                                                    color: theme.colorScheme.onSurface,
                                                  ),
                                                  Icon(
                                                    LucideIcons.chevron_down,
                                                    size: 22,
                                                    color: theme.colorScheme.onSurface,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  MySpacing.height(16),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: MyContainer.bordered(
                                      paddingAll: 0,
                                      child: DataTable(
                                          sortAscending: true,
                                          onSelectAll: (_) => {},
                                          headingRowColor: WidgetStatePropertyAll(contentTheme.primary.withAlpha(40)),
                                          dataRowMaxHeight: 50,
                                          columns: [
                                            DataColumn(
                                              label: MyText.labelLarge(
                                                'Value',
                                              ),
                                            ),
                                            DataColumn(
                                              label: MyText.labelLarge(
                                                'Sum',
                                              ),
                                            ),
                                            DataColumn(
                                              label: MyText.labelLarge(
                                                'Metric',
                                              ),
                                            ),
                                            DataColumn(
                                              label: MyText.labelLarge(
                                                'Tag',
                                              ),
                                            ),
                                          ],
                                          rows: controller.dashboard
                                              .mapIndexed(
                                                (index, data) => DataRow(
                                                  cells: [
                                                    DataCell(
                                                      MyText.bodyMedium("${data.value}"),
                                                    ),
                                                    DataCell(
                                                      MyText.bodyMedium("${data.sum}"),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          MyContainer(
                                                            paddingAll: 0,
                                                            borderRadiusAll: 22,
                                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                                            child: Image.asset(
                                                              controller.dashboard[index].image,
                                                              height: 32,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          MySpacing.width(16),
                                                          Expanded(
                                                            child: MyText.bodyMedium(
                                                              data.metric,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      MyText.bodyMedium(data.tag),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          MyFlexItem(
                            sizes: "lg-6",
                            child: MyCard(
                              shadow: MyShadow(elevation: 0.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: MySpacing.x(8),
                                        child: MyText.titleMedium(
                                          "Revenue Chart",
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: 600,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            LucideIcons.move_right,
                                            size: 20,
                                          ))
                                    ],
                                  ),
                                  MySpacing.height(16),
                                  SizedBox(
                                    height: 308,
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      tooltipBehavior: controller.revenue,
                                      primaryXAxis: CategoryAxis(
                                        majorGridLines: const MajorGridLines(width: 0),
                                      ),
                                      primaryYAxis: NumericAxis(
                                          // majorGridLines:
                                          // const MajorGridLines(width: 0),
                                          ),
                                      series: [
                                        SplineSeries<ChartSampleData, String>(
                                          color: const Color(0xff727cf5),
                                          dataLabelSettings: const DataLabelSettings(
                                            borderWidth: 100,
                                            showZeroValue: true,
                                          ),
                                          dataSource: controller.revenueChart1,
                                          xValueMapper: (ChartSampleData data, _) => data.x,
                                          yValueMapper: (ChartSampleData data, _) => data.y,
                                        ),
                                        SplineSeries<ChartSampleData, String>(
                                          color: const Color(0xff0acf97),
                                          dataSource: controller.revenueChart2,
                                          xValueMapper: (ChartSampleData data, _) => data.x,
                                          yValueMapper: (ChartSampleData data, _) => data.y,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCircleChartData(Color color, String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyContainer.rounded(
              paddingAll: 4,
              color: color,
            ),
            MySpacing.width(8),
            MyText.bodyMedium(name)
          ],
        ),
        MyText.bodyMedium(price),
      ],
    );
  }

  Widget buildResponseTimeByLocationData(String currentTime, String price, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circle_dot_dashed,
              size: 16,
            ),
            MySpacing.width(8),
            MyText.bodyMedium(
              currentTime,
            ),
          ],
        ),
        MySpacing.height(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText.bodyLarge(
              price,
              fontSize: 20,
              fontWeight: 600,
              muted: true,
            ),
            MySpacing.width(8),
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCard(
    Color color,
    IconData icons,
    String accountType,
    String price,
    IconData trendingIcon,
    Color trendingIconColor,
    String percentage,
    String month,
  ) {
    return MyCard(
      shadow: MyShadow(elevation: 0.5),
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyLarge(
                  accountType,
                  fontSize: 15,
                  fontWeight: 600,
                ),
                MyText.bodyLarge(
                  price,
                  fontWeight: 600,
                  fontSize: 20,
                ),
                Row(
                  children: [
                    Icon(
                      trendingIcon,
                      color: trendingIconColor,
                      size: 16,
                    ),
                    MySpacing.width(8),
                    MyText.bodyMedium(
                      "$percentage%",
                    ),
                    MySpacing.width(8),
                    Expanded(
                      child: MyText.bodyMedium(
                        month,
                        overflow: TextOverflow.ellipsis,
                        muted: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MyContainer(
            height: 70,
            width: 70,
            paddingAll: 0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: color.withAlpha(30),
            child: Icon(
              icons,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:webkit/helpers/theme/admin_theme.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_flex.dart';
import 'package:webkit/helpers/widgets/my_flex_item.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';

import 'package:webkit/views/layouts/layout.dart';
import 'package:webkit/views/apps/dashboard/models/dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  /// ✅ Controller injected ONCE
  final DashboardController controller =
  Get.put(DashboardController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    const double gap = 16;

    return Layout(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: MySpacing.xy(gap, gap / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Dashboard",
                    fontSize: 22,
                    fontWeight: 700,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Dashboard', active: true),
                    ],
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ================= STATS =================
              MyFlex(
                contentPadding: false,
                children: [
                  statCard("Total Users", controller.totalUsers, LucideIcons.users, contentTheme.primary),
                  statCard("Paid Users", controller.paidUsers, LucideIcons.user_check, contentTheme.success),
                  statCard("Free Users", controller.freeUsers, LucideIcons.user_minus, contentTheme.warning),
                  statCard("Resolved", controller.ticketsResolved, LucideIcons.check_check, contentTheme.info),
                  statCard("In Progress", controller.ticketsInProgress, LucideIcons.clock, contentTheme.danger),
                  statCard("Total Revenue", controller.totalRevenue, LucideIcons.dollar_sign, contentTheme.success),
                  statCard("Pending Revenue", controller.pendingRevenue, LucideIcons.triangle_alert, contentTheme.danger),

                ],
              ),
              MySpacing.height(gap),

              // ================= CHART + COUNTRY =================
              MyFlex(
                contentPadding: false,
                children: [
                  // Revenue Chart
                  MyFlexItem(
                    sizes: "lg-6 md-12 sm-12",
                    child: MyCard(
                      padding: MySpacing.all(16),
                      shadow: MyShadow(elevation: .6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.titleMedium("Revenue by Plan Type", fontWeight: 600),
                          MySpacing.height(12),
                          SizedBox(
                            height: 260,
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ColumnSeries<int, String>>[
                                ColumnSeries<int, String>(
                                  width: .45,
                                  borderRadius: BorderRadius.circular(6),
                                  color: contentTheme.primary,
                                  dataSource: [
                                    controller.readymadeSold.value,
                                    controller.customSold.value,
                                    controller.specialSold.value,
                                  ],
                                  xValueMapper: (v, i) => ["Readymade", "Custom", "Special"][i],
                                  yValueMapper: (v, _) => v,
                                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= USERS BY COUNTRY (IMPROVED UI) =================
                  MyFlexItem(
                    sizes: "lg-6 md-12 sm-12",
                    child: MyCard(
                      padding: MySpacing.all(16),
                      shadow: MyShadow(elevation: .6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.globe, size: 18),
                              MySpacing.width(8),
                              MyText.titleMedium("Users by Country", fontWeight: 600),
                            ],
                          ),
                          MySpacing.height(16),

                          SizedBox(
                            height: 260,
                            child: Obx(() {
                              if (controller.usersByCountry.isEmpty) {
                                return Center(
                                  child: MyText.bodySmall("No data available", muted: true),
                                );
                              }

                              final total = controller.usersByCountry.values
                                  .fold<int>(0, (a, b) => a + b);

                              return ListView.separated(
                                itemCount: controller.usersByCountry.length,
                                separatorBuilder: (_, __) => MySpacing.height(12),
                                itemBuilder: (context, index) {
                                  final entry =
                                  controller.usersByCountry.entries.elementAt(index);

                                  double percent =
                                  total == 0 ? 0 : (entry.value / total);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ---------- HEADER ROW ----------
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: AdminTheme
                                                    .theme.contentTheme.primary
                                                    .withOpacity(.15),
                                                child: MyText.bodySmall(
                                                  entry.key.substring(0, 1).toUpperCase(),
                                                  fontWeight: 600,
                                                ),
                                              ),
                                              MySpacing.width(10),
                                              MyText.bodyMedium(
                                                entry.key,
                                                fontWeight: 600,
                                              ),
                                            ],
                                          ),
                                          MyText.bodyMedium(
                                            entry.value.toString(),
                                            fontWeight: 600,
                                          ),
                                        ],
                                      ),

                                      MySpacing.height(6),

                                      // ---------- PROGRESS BAR ----------
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          minHeight: 6,
                                          value: percent,
                                          backgroundColor: Colors.grey.withOpacity(.15),
                                          valueColor: AlwaysStoppedAnimation(
                                            AdminTheme.theme.contentTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
              MySpacing.height(gap),

              // ================= USERS + POPULAR PLANS =================
              MyFlex(
                contentPadding: false,
                children: [
                  // Users Table
                  MyFlexItem(
                    sizes: "lg-8 md-12 sm-12",
                    child: usersTable(contentTheme),
                  ),

                  // Popular Plans
                  MyFlexItem(
                    sizes: "lg-4 md-12 sm-12",
                    child: popularPlansTable(),
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ================= SUPPORT TICKETS =================
              supportTicketsTable(contentTheme),
              MySpacing.height(gap),

              transactionReportTable(),
              MySpacing.height(gap),

              userLedgerReport(),
              MySpacing.height(gap),

            ],
          ),
        );
      }),
    );
  }

  Widget transactionReportTable() {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.credit_card, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("All Transactions", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),

          SizedBox(
            height: 380,
            child: Obx(() {
              if (controller.transactions.isEmpty) {
                return Center(child: MyText.bodySmall("No transactions found"));
              }

              return ListView.separated(
                itemCount: controller.transactions.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (_, i) {
                  final t = controller.transactions[i];

                  Color color = t['status'] == 'completed'
                      ? Colors.green
                      : Colors.orange;

                  return Row(
                    children: [
                      Expanded(child: MyText.bodySmall(t['plan'] ?? '-')),
                      Expanded(child: MyText.bodySmall("\$${t['amount']}")),
                      Expanded(
                        child: MyText.bodySmall(
                          t['status'],
                          color: color,
                        ),
                      ),
                      Expanded(
                        child: MyText.bodySmall(
                          t['date'] != null
                              ? (t['date'] as Timestamp).toDate().toString()
                              : "-",
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

  Widget userLedgerReport() {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.book_open, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("User Ledgers", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),

          SizedBox(
            height: 380,
            child: Obx(() {
              if (controller.userLedgers.isEmpty) {
                return Center(child: MyText.bodySmall("No ledger data"));
              }

              return ListView.separated(
                itemCount: controller.userLedgers.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (_, i) {
                  final l = controller.userLedgers[i];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium(
                        "User ID: ${l['userId']}",
                        fontWeight: 600,
                      ),

                      MySpacing.height(6),

                      Row(
                        children: [
                          Expanded(
                            child: MyText.bodySmall(
                              "Total Paid: \$${l['totalPaid']}",
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: MyText.bodySmall(
                              "Pending: \$${l['pending']}",
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      MySpacing.height(6),

                      MyText.bodySmall(
                        "Total Transactions: ${l['plans'].length}",
                        muted: true,
                      ),
                    ],
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }


  // ================= STAT CARD =================
  MyFlexItem statCard(String title, Rx<num> value, IconData icon, Color color) {
    return MyFlexItem(
      sizes: "lg-2 md-4 sm-6",
      child: Obx(() {
        return MyCard(
          height: 90,
          padding: MySpacing.xy(12, 10),
          shadow: MyShadow(elevation: .4),
          child: Row(
            children: [
              MyContainer(
                height: 36,
                width: 36,
                color: color.withOpacity(.15),
                borderRadiusAll: 8,
                child: Icon(icon, size: 18, color: color),
              ),
              MySpacing.width(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText.titleMedium(
                    value.value.toStringAsFixed(0),
                    fontWeight: 600,
                  ),
                  MyText.bodySmall(title, muted: true),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

// ================= USERS & MEMBERSHIP (FIXED HEIGHT + IMPROVED UI) =================
  Widget usersTable(ContentTheme contentTheme) {
    const double tableHeight = 380; // same as popularPlansTable

    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.users, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("Users & Membership", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),

          Obx(() {
            if (controller.users.isEmpty) {
              return Center(
                child: MyText.bodySmall("No users data available", muted: true),
              );
            }

            return SizedBox(
              height: tableHeight,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.users.length,
                  separatorBuilder: (_, __) => MySpacing.height(12),
                  itemBuilder: (context, index) {
                    final u = controller.users[index];
                    final plan = u['plan_name'] ?? 'Free';
                    final planColor = plan == 'Premium' ? Colors.green : Colors.orange;
                    final purchases = u['purchases'] as List<Map<String, dynamic>>? ?? [];

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.withOpacity(0.03),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // -------- USER HEADER ----------
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: u['avatar_url'] != null
                                    ? NetworkImage(u['avatar_url'])
                                    : null,
                                backgroundColor: contentTheme.primary.withOpacity(.2),
                                child: u['avatar_url'] == null
                                    ? Text(u['name'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.bodyMedium(u['name'] ?? '-', fontWeight: 600),
                                    Row(
                                      children: [
                                        Icon(Icons.email, size: 14, color: Colors.grey),
                                        MySpacing.width(4),
                                        MyText.bodySmall(u['email'] ?? '-', muted: true),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                                        MySpacing.width(4),
                                        MyText.bodySmall(u['country'] ?? '-', muted: true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(plan),
                                backgroundColor: planColor.withOpacity(.15),
                                labelStyle: TextStyle(color: planColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),

                          MySpacing.height(8),

                          // -------- PURCHASE HISTORY SCROLLABLE INSIDE FIXED ROW ----------
                          if (purchases.isNotEmpty)
                            SizedBox(
                              height: 80, // fixed height for all purchase history rows
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: purchases.length,
                                separatorBuilder: (_, __) => MySpacing.height(4),
                                itemBuilder: (context, pIndex) {
                                  final p = purchases[pIndex];
                                  final amount = p['amount'] ?? 0;
                                  final planName = p['plan_name'] ?? '-';
                                  final purchaseDate = p['purchase_date'] != null
                                      ? (p['purchase_date'] as Timestamp).toDate()
                                      : null;
                                  final expiryDate = p['expiry_date'] != null
                                      ? (p['expiry_date'] as Timestamp).toDate()
                                      : null;
                                  final status = p['payment_status'] ?? '-';

                                  Color statusColor = status.toLowerCase() == 'pending'
                                      ? Colors.orange
                                      : Colors.green;

                                  return Row(
                                    children: [
                                      Expanded(flex: 2, child: MyText.bodySmall(planName)),
                                      Expanded(
                                        flex: 2,
                                        child: MyText.bodySmall(
                                          purchaseDate != null
                                              ? "${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}"
                                              : "-",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: MyText.bodySmall(
                                          expiryDate != null
                                              ? "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}"
                                              : "-",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: MyText.bodySmall(
                                          status,
                                          color: statusColor,
                                        ),
                                      ),
                                      Expanded(flex: 1, child: MyText.bodySmall("\$$amount")),
                                    ],
                                  );
                                },
                              ),
                            )
                          else
                            MyText.bodySmall("No purchases yet", muted: true),

                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }



// ================= POPULAR PLANS (IMPROVED UI) =================
  Widget popularPlansTable() {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trending_up, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("Most Popular Plans", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),

          Obx(() {
            if (controller.popularPlans.isEmpty) {
              return Center(
                child: MyText.bodySmall("No plans data available", muted: true),
              );
            }

            final maxSold =
                controller.popularPlans.first['sold'] ?? 1;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.popularPlans.length,
              separatorBuilder: (_, __) => MySpacing.height(14),
              itemBuilder: (context, index) {
                final p = controller.popularPlans[index];
                final sold = p['sold'] ?? 0;
                final percent =
                maxSold == 0 ? 0.0 : sold / maxSold;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- HEADER ----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Rank badge
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AdminTheme
                                    .theme.contentTheme.primary
                                    .withOpacity(.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: MyText.bodySmall(
                                "#${index + 1}",
                                fontWeight: 600,
                              ),
                            ),
                            MySpacing.width(10),

                            MyText.bodyMedium(
                              p['title'],
                              fontWeight: 600,
                            ),
                          ],
                        ),

                        MyText.bodyMedium(
                          "$sold sold",
                          fontWeight: 600,
                        ),
                      ],
                    ),

                    MySpacing.height(6),

                    // ---------- PROGRESS ----------
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: percent,
                        backgroundColor:
                        Colors.grey.withOpacity(.15),
                        valueColor: AlwaysStoppedAnimation(
                          AdminTheme.theme.contentTheme.primary,
                        ),
                      ),
                    ),

                    MySpacing.height(4),

                    // ---------- FOOTER ----------
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyText.bodySmall(
                        "${(percent * 100).toStringAsFixed(1)}% of top plan",
                        muted: true,
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

// ================= SUPPORT TICKETS (IMPROVED UI) =================
  Widget supportTicketsTable(ContentTheme contentTheme) {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.headphones, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("Support Tickets", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),

          SizedBox(
            height: 360, // Same height as users/popularPlans tables
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.firestore
                  .collection('support_tickets')
                  .limit(15)
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = snap.data!.docs
                    .map((d) => d.data() as Map<String, dynamic>)
                    .toList();

                if (tickets.isEmpty) {
                  return Center(
                    child: MyText.bodySmall("No tickets found", muted: true),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => MySpacing.height(14),
                  itemBuilder: (context, index) {
                    final t = tickets[index];

                    // Status color
                    Color statusColor;
                    switch ((t['status'] ?? 'In Progress').toLowerCase()) {
                      case 'resolved':
                        statusColor = Colors.green;
                        break;
                      case 'in progress':
                        statusColor = Colors.orange;
                        break;
                      case 'pending':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    // Priority color
                    Color priorityColor;
                    switch ((t['priority'] ?? 'Normal').toLowerCase()) {
                      case 'high':
                        priorityColor = Colors.redAccent;
                        break;
                      case 'medium':
                        priorityColor = Colors.orangeAccent;
                        break;
                      default:
                        priorityColor = Colors.greenAccent;
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ---------- USER ----------
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                contentTheme.primary.withOpacity(.15),
                                child: MyText.bodySmall(
                                  (t['userName'] ?? '-')[0].toUpperCase(),
                                  fontWeight: 700,
                                ),
                              ),
                              MySpacing.width(8),
                              Expanded(
                                child: MyText.bodyMedium(
                                  t['userName'] ?? '-',
                                  fontWeight: 600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---------- TOPIC ----------
                        Expanded(
                          flex: 3,
                          child: MyText.bodySmall(
                            t['topic'] ?? '-',
                          ),
                        ),

                        // ---------- STATUS ----------
                        Expanded(
                          flex: 2,
                          child: MyContainer(
                            padding: MySpacing.xy(12, 6),
                            borderRadiusAll: 12,
                            color: statusColor.withOpacity(.2),
                            child: MyText.bodySmall(
                              t['status'] ?? '-',
                              color: statusColor,
                              fontWeight: 600,
                            ),
                          ),
                        ),

                        // ---------- PRIORITY ----------
                        Expanded(
                          flex: 2,
                          child: MyContainer(
                            padding: MySpacing.xy(12, 6),
                            borderRadiusAll: 12,
                            color: priorityColor.withOpacity(.2),
                            child: MyText.bodySmall(
                              t['priority'] ?? '-',
                              color: priorityColor,
                              fontWeight: 600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget activeMembershipsTable() {
    return MyCard(
      padding: MySpacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Active Memberships"),

          SizedBox(
            height: 380,
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.activeMemberships.length,
                itemBuilder: (_, i) {
                  final m = controller.activeMemberships[i];

                  return Row(
                    children: [
                      Expanded(child: MyText.bodySmall(m['userName'])),
                      Expanded(child: MyText.bodySmall(m['planName'])),
                      Expanded(child: MyText.bodySmall("\$${m['amount']}")),
                    ],
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
  Widget pendingPaymentsTable() {
    return MyCard(
      padding: MySpacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Pending Payments"),

          SizedBox(
            height: 380,
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.pendingPayments.length,
                itemBuilder: (_, i) {
                  final p = controller.pendingPayments[i];

                  return Row(
                    children: [
                      Expanded(child: MyText.bodySmall(p['userName'])),
                      Expanded(child: MyText.bodySmall(p['planName'])),
                      Expanded(child: MyText.bodySmall("\$${p['amount']}")),
                    ],
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

}
