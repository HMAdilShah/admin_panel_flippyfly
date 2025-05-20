import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:webkit/controller/my_controller.dart';
import 'package:webkit/helpers/theme/app_theme.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';

class PolylineModel {
  PolylineModel(this.points);

  final List<MapLatLng> points;
}

class LogisticDashboardController extends MyController with UIMixin {
  TooltipBehavior? columnToolTip;
  List<ChartSampleData>? chartData;
  List<ChartData>? analytic;
  late MapShapeSource dataSource;
  late List<PolylineModel> polyLines;
  late List<MapLatLng> polyline;
  late int selectedIndex;
  late MapZoomPanBehavior zoomPanBehavior;

  @override
  void onInit() {
    dataSource = MapShapeSource.asset('assets/datas/world_map.json',
        shapeDataField: 'name');
    selectedIndex = -1;
    zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 2,
      focalLatLng: MapLatLng(19.3173, 76.7139),
    );
    polyline = <MapLatLng>[
      MapLatLng(13.0827, 80.2707),
      MapLatLng(13.1746, 79.6117),
      MapLatLng(13.6373, 79.5037),
      MapLatLng(14.4673, 78.8242),
      MapLatLng(14.9091, 78.0092),
      MapLatLng(16.2160, 77.3566),
      MapLatLng(17.1557, 76.8697),
      MapLatLng(18.0975, 75.4249),
      MapLatLng(18.5204, 73.8567),
      MapLatLng(19.0760, 72.8777),
    ];

    polyLines = <PolylineModel>[
      PolylineModel(polyline),
    ];
    columnToolTip = TooltipBehavior(enable: true);

    analytic = <ChartData>[
      ChartData(2010, 6.6, 9.0, 15.1, 18.8),
      ChartData(2011, 6.3, 9.3, 15.5, 18.5),
      ChartData(2012, 6.7, 10.2, 14.5, 17.6),
      ChartData(2013, 6.7, 10.2, 13.9, 16.1),
      ChartData(2014, 6.4, 10.9, 13, 17.2),
      ChartData(2015, 6.8, 9.3, 13.4, 18.9),
      ChartData(2016, 7.7, 10.1, 14.2, 19.4),
    ];

    chartData = <ChartSampleData>[
      ChartSampleData(x: 'Sun', y: 16, secondSeriesYValue: 8),
      ChartSampleData(x: 'Mon', y: 8, secondSeriesYValue: 10),
      ChartSampleData(x: 'Tue', y: 12, secondSeriesYValue: 10),
      ChartSampleData(x: 'Wed', y: 4, secondSeriesYValue: 8),
      ChartSampleData(x: 'The', y: 6, secondSeriesYValue: 17),
      ChartSampleData(x: 'Fri', y: 7, secondSeriesYValue: 4),
      ChartSampleData(x: 'Sat', y: 15, secondSeriesYValue: 9),
    ];

    super.onInit();
  }

  void isSelectIndex(index) {
    selectedIndex = index;
    update();
  }

  List<LineSeries<ChartData, num>> analyticsChart() {
    return <LineSeries<ChartData, num>>[
      LineSeries<ChartData, num>(
          dashArray: <double>[15, 3, 3, 3],
          dataSource: analytic,
          color: contentTheme.primary,
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y,
          name: 'Singapore',
          markerSettings: MarkerSettings(isVisible: true)),
      LineSeries<ChartData, num>(
          dataSource: analytic,
          color: contentTheme.secondary,
          dashArray: <double>[15, 3, 3, 3],
          name: 'Saudi Arabia',
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y2,
          markerSettings: MarkerSettings(isVisible: true)),
      LineSeries<ChartData, num>(
          dataSource: analytic,
          color: contentTheme.info,
          dashArray: <double>[15, 3, 3, 3],
          name: 'Spain',
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y3,
          markerSettings: MarkerSettings(isVisible: true)),
      LineSeries<ChartData, num>(
          dataSource: analytic,
          color: contentTheme.success,
          dashArray: <double>[15, 3, 3, 3],
          name: 'Portugal',
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y4,
          markerSettings: MarkerSettings(isVisible: true)),
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> getDefaultColumn() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
          width: .9,
          spacing: .2,
          dataSource: chartData,
          color: theme.colorScheme.primary,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
          name: 'Income'),
      ColumnSeries<ChartSampleData, String>(
          dataSource: chartData,
          width: .8,
          spacing: .2,
          color: theme.colorScheme.secondary,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
          name: 'Spend'),
    ];
  }
}

class ChartSampleData {
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  final dynamic x;
  final num? y;
  final dynamic xValue;
  final num? yValue;
  final num? secondSeriesYValue;
  final num? thirdSeriesYValue;
  final Color? pointColor;
  final num? size;
  final String? text;
  final num? open;
  final num? close;
  final num? low;
  final num? high;
  final num? volume;
}

class ChartData {
  ChartData(this.x, this.y, this.y2, this.y3, this.y4);

  final double x;
  final double y;
  final double y2;
  final double y3;
  final double y4;
}
