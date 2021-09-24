import 'package:flutter/material.dart';
import 'package:technixo_k_chart_v2/utils/number_util.dart';


import '../chart_style.dart';

export '../chart_style.dart';

abstract class BaseChartRenderer<T> {
  double maxValue, minValue;
  late double scaleY, scaleX;
  double topPadding;
  Rect chartRect;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;
  late final Paint gridPaint;

  BaseChartRenderer(
    this.chartColors,
    this.chartStyle, {
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.scaleX,
  }) {
    gridPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 0.5
      ..color = chartColors.gridColor;
    if (maxValue == minValue) {
      maxValue += 0.5;
      minValue -= 0.5;
    }
    scaleY = chartRect.height / (maxValue - minValue);
  }

  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  String format(double n) {
    return NumberUtil.format(n);
  }

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawRightText(canvas, textStyle, int gridRows);

  void drawChart(T lastPoint, T curPoint, double lastX, double curX, Size size,
      Canvas canvas, List<double> strokes);

  void drawLine(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX, Color color,double strokes) {
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    final paint = Paint();
    paint.strokeWidth = 10;
    canvas.drawLine(
        Offset(lastX, lastY), Offset(curX, curY), chartPaint..color = color..strokeWidth=strokes..strokeCap=StrokeCap.round);
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: chartStyle.defaultTextSize, color: color);
  }
}
