import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';

import '../entity/info_window_entity.dart';
import '../entity/k_line_entity.dart';
import '../utils/date_format_util.dart';
import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';
import 'secondary_renderer.dart';
import 'vol_renderer.dart';

class ChartPainter extends BaseChartPainter {
  static get maxScrollX => BaseChartPainter.maxScrollX;
  late BaseChartRenderer mMainRenderer;
  BaseChartRenderer? mVolRenderer, mSecondaryRenderer;
  StreamSink<InfoWindowEntity?>? sink;
  AnimationController? controller;
  double opacity;
  List<int> maDayList;
  List<int> emaDayList;
  List<Color>? bgColor;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  List<double> strokesMainrender;
  List<double> strokeSecondState;

  ChartPainter(
    this.chartColors,
    this.chartStyle, {
    required this.strokesMainrender,
    required this.strokeSecondState,
    required List<KLineEntity> datas,
    required scaleX,
    required scrollX,
    required isLongPass,
    required selectX,
    required String text,
    required TextStyle textStyle,
    required this.maDayList,
    required this.emaDayList,
    mainState,
    volHidden,
    secondaryState,
    this.sink,
    bool isLine = false,
    this.controller,
    this.opacity = 0.0,
    this.bgColor,
  })  : assert(bgColor == null || bgColor.length >= 2),
        super(
          chartStyle,
          datas: datas,
          text: text,
          textStyle: textStyle,
          scaleX: scaleX,
          scrollX: scrollX,
          isLongPress: isLongPass,
          selectX: selectX,
          mainState: mainState,
          volHidden: volHidden,
          secondaryState: secondaryState,
          isLine: isLine,
        );

  @override
  void initChartRenderer() {
    mMainRenderer = MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      chartStyle.topPadding,
      mainState,
      isLine,
      scaleX,
      maDayList,
      emaDayList,
      chartColors,
      chartStyle,
    );
    if (mVolRect != null) {
      mVolRenderer ??= VolRenderer(
        mVolRect!,
        mVolMaxValue,
        mVolMinValue,
        chartStyle.childPadding,
        scaleX,
        chartColors,
        chartStyle,
      );
    }
    if (mSecondaryRect != null) {
      mSecondaryRenderer ??= SecondaryRenderer(
        mSecondaryRect!,
        mSecondaryMaxValue,
        mSecondaryMinValue,
        chartStyle.childPadding,
        secondaryState,
        scaleX,
        chartColors,
        chartStyle,
      );
    }
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    Rect mainRect = Rect.fromLTRB(
        0, 0, mMainRect.width, mMainRect.height + chartStyle.topPadding);
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: bgColor ?? [Color(0xff18191d), Color(0xff18191d)],
    );
    final Paint mBgPaint = bgColor != null
        ? (Paint()..shader = mBgGradient.createShader(mainRect))
        : (Paint()..color = chartColors.bgColor);
    canvas.drawRect(mainRect, mBgPaint);

    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(0, mVolRect!.top - chartStyle.childPadding,
          mVolRect!.width, mVolRect!.bottom);
      canvas.drawRect(volRect, mBgPaint);
    }

    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(
          0,
          mSecondaryRect!.top - chartStyle.childPadding,
          mSecondaryRect!.width,
          mSecondaryRect!.bottom);
      canvas.drawRect(secondaryRect, mBgPaint);
    }
    Rect dateRect = Rect.fromLTRB(
        0, size.height - chartStyle.bottomDateHigh, size.width, size.height);
    canvas.drawRect(dateRect, mBgPaint);
  }

  @override
  void drawGrid(canvas) {
    mMainRenderer.drawGrid(canvas, chartStyle.gridRows, chartStyle.gridColumns);
    mVolRenderer?.drawGrid(canvas, chartStyle.gridRows, chartStyle.gridColumns);
    mSecondaryRenderer?.drawGrid(
        canvas, chartStyle.gridRows, chartStyle.gridColumns);
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      KLineEntity curPoint = datas[i];
      KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas, strokesMainrender);
      mVolRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas, strokesMainrender);
      mSecondaryRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas, strokeSecondState);
    }

    if (isLongPress == true) drawCrossLine(canvas, size);
    canvas.restore();
  }

  @override
  void drawRightText(canvas) {
    var textStyle = getTextStyle(chartColors.yAxisTextColor);
    mMainRenderer.drawRightText(canvas, textStyle, chartStyle.gridRows);
    mVolRenderer?.drawRightText(canvas, textStyle, chartStyle.gridRows);
    mSecondaryRenderer?.drawRightText(canvas, textStyle, chartStyle.gridRows);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    double columnSpace = size.width / chartStyle.gridColumns;
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double y = 0.0;
    for (var i = 0; i <= chartStyle.gridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);
      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);
        TextPainter tp = getTextPainter(getDate(datas[index].id!),
            color: chartColors.xAxisTextColor);
        y = size.height -
            (chartStyle.bottomDateHigh - tp.height) / 2 -
            tp.height;
        tp.paint(canvas, Offset(columnSpace * i - tp.width / 2, y));
      }
    }
  }

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    Paint selectPointPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..color = chartColors.markerBgColor;
    Paint selectorBorderPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..color = chartColors.markerBorderColor;

    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    TextPainter tp =
        getTextPainter(format(point.close), color: chartColors.infoText);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = mWidth - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(mWidth - 2, y + r);
      path.lineTo(mWidth - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter dateTp =
        getTextPainter(getDate(point.id!), color: chartColors.infoText);
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = size.height - chartStyle.bottomDateHigh;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectPointPaint);
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectorBorderPaint);

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));
    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //长按显示按中的数据
    if (isLongPress) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    //松开显示最后一条数据
    mMainRenderer.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;
    //绘制最大值和最小值
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter("── ${format(mMainLowMinValue)}",
          color: chartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter("${format(mMainLowMinValue)} ──",
          color: chartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter("── ${format(mMainHighMaxValue)}",
          color: chartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter("${format(mMainHighMaxValue)} ──",
          color: chartColors.maxMinTextColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  ///画交叉线
  void drawCrossLine(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);
    Paint paintY = Paint()
      ..color = chartColors.yCrossLine
      ..strokeWidth = chartStyle.vCrossWidth
      ..isAntiAlias = true;
    double x = getX(index);
    double y = getMainY(point.close);
    // k线图竖线
    canvas.drawLine(Offset(x, chartStyle.topPadding),
        Offset(x, size.height - chartStyle.bottomDateHigh), paintY);

    Paint paintX = Paint()
      ..color = chartColors.xCrossLine
      ..strokeWidth = chartStyle.hCrossWidth
      ..isAntiAlias = true;
    // k线图横线
    canvas.drawLine(Offset(-mTranslateX, y),
        Offset(-mTranslateX + mWidth / scaleX, y), paintX);
//    canvas.drawCircle(Offset(x, y), 2.0, paintX);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0 * scaleX, width: 2.0),
        paintX);
  }

  final Paint realTimePaint = Paint()
        ..strokeWidth = 1.0
        ..isAntiAlias = true,
      pointPaint = Paint();

  ///画实时价格线
  @override
  void drawRealTimePrice(Canvas canvas, Size size) {
    if (mMarginRight == 0 || datas.isEmpty == true) return;
    KLineEntity point = datas.last;
    TextPainter tp = getTextPainter(format(point.close),
        color: chartColors.rightRealTimeTextColor);
    double y = getMainY(point.close);
    //max越往右边滑值越小
    var max = (mTranslateX.abs() +
            mMarginRight -
            getMinTranslateX().abs() +
            mPointWidth) *
        scaleX;
    double x = mWidth - max;
    if (!isLine) x += mPointWidth / 2;
    var dashWidth = 10;
    var dashSpace = 5;
    double startX = 0;
    final space = (dashSpace + dashWidth);
    if (tp.width < max) {
      while (startX < max) {
        canvas.drawLine(
            Offset(x + startX, y),
            Offset(x + startX + dashWidth, y),
            realTimePaint..color = chartColors.realTimeLineColor);
        startX += space;
      }
      //画一闪一闪
      if (isLine) {
        startAnimation();
        Gradient pointGradient = RadialGradient(
            colors: [Colors.white.withOpacity(opacity), Colors.transparent]);
        pointPaint.shader = pointGradient
            .createShader(Rect.fromCircle(center: Offset(x, y), radius: 14.0));
        canvas.drawCircle(Offset(x, y), 14.0, pointPaint);
        canvas.drawCircle(
            Offset(x, y), 2.0, realTimePaint..color = Colors.white);
      } else {
        stopAnimation(); //停止一闪闪
      }
      double left = mWidth - tp.width;
      double top = y - tp.height / 2;
      canvas.drawRect(
          Rect.fromLTRB(left, top, left + tp.width, top + tp.height),
          realTimePaint..color = chartColors.realTimeBgColor);
      tp.paint(canvas, Offset(left, top));
    } else {
      stopAnimation(); //停止一闪闪
      startX = 0;
      if (point.close > mMainMaxValue) {
        y = getMainY(mMainMaxValue);
      } else if (point.close < mMainMinValue) {
        y = getMainY(mMainMinValue);
      }
      while (startX < mWidth) {
        canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y),
            realTimePaint..color = chartColors.realTimeLongLineColor);
        startX += space;
      }

      const padding = 3.0;
      const triangleHeight = 8.0; //三角高度
      const triangleWidth = 5.0; //三角宽度

      double left =
          mWidth - mWidth / chartStyle.gridColumns - tp.width / 2 - padding * 2;
      double top = y - tp.height / 2 - padding;
      //加上三角形的宽以及padding
      double right = left + tp.width + padding * 2 + triangleWidth + padding;
      double bottom = top + tp.height + padding * 2;
      double radius = (bottom - top) / 2;
      //画椭圆背景
      RRect rectBg1 =
          RRect.fromLTRBR(left, top, right, bottom, Radius.circular(radius));
      RRect rectBg2 = RRect.fromLTRBR(left - 1, top - 1, right + 1, bottom + 1,
          Radius.circular(radius + 2));
      canvas.drawRRect(
          rectBg2, realTimePaint..color = chartColors.realTimeTextBorderColor);
      canvas.drawRRect(
          rectBg1, realTimePaint..color = chartColors.realTimeBgColor);
      tp = getTextPainter(format(point.close),
          color: chartColors.realTimeTextColor);
      Offset textOffset = Offset(left + padding, y - tp.height / 2);
      tp.paint(canvas, textOffset);
      //画三角
      Path path = Path();
      double dx = tp.width + textOffset.dx + padding;
      double dy = top + (bottom - top - triangleHeight) / 2;
      path.moveTo(dx, dy);
      path.lineTo(dx + triangleWidth, dy + triangleHeight / 2);
      path.lineTo(dx, dy + triangleHeight);
      path.close();
      canvas.drawPath(
          path,
          realTimePaint
            ..color = chartColors.realTimeTextColor
            ..shader = null);
    }
  }

  TextPainter getTextPainter(text, {color = Colors.white}) {
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(int date) =>
      dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000), mFormats);

  double getMainY(double y) => mMainRenderer.getY(y);

  void startAnimation() {
    if (controller?.isAnimating != true) controller?.repeat(reverse: true);
  }

  void stopAnimation() {
    if (controller?.isAnimating == true) controller?.stop();
  }

  @override
  void drawLabel(Canvas canvas, Size size) {
    final TextSpan span = TextSpan(text: text, style: textStyle);
    final TextPainter tp =
        TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    final Offset position = Offset(0 + 10, size.height - tp.height - 22);
    tp.paint(canvas, position);
  }
}
