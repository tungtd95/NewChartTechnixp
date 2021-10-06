import 'package:flutter/material.dart';
import 'package:technixo_k_chart_v2/utils/n_interval.dart';

import '../entity/candle_entity.dart';
import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  double mCandleWidth;
  double mCandleLineWidth;

  MainState state;
  bool isLine;
  List<int> maDayList;
  List<int> emaDayList;
  double _contentPadding = 12.0;
  final ChartColors chartColors;
  final ChartStyle chartStyle;

  MainRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    this.isLine,
    double scaleX,
    this.maDayList,
    this.emaDayList,
    this.chartColors,
    this.chartStyle,
  )   : mCandleWidth = chartStyle.candleWidth,
        mCandleLineWidth = chartStyle.candleLineWidth,
        super(
          chartColors,
          chartStyle,
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          scaleX: scaleX,
        ) {
    var diff = maxValue - minValue; //计算差
    var newScaleY = (chartRect.height - _contentPadding) / diff; //内容区域高度/差=新的比例
    var newDiff = chartRect.height / newScaleY; //高/新比例=新的差
    var value = (newDiff - diff) / 2; //新差-差/2=y轴需要扩大的值
    if (newDiff > diff) {
      this.scaleY = newScaleY;
      this.maxValue += value;
      this.minValue -= value;
    }
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    TextSpan? span;
    if (state == MainState.MA) {
      span = TextSpan(children: _createMATextSpan(data));
    } else if (state == MainState.EMA) {
      span = TextSpan(children: _createEMATextSpan(data));
    } else if (state == MainState.BOLL) {
      span = TextSpan(
        children: [
          if (data.mb != 0)
            TextSpan(
                text: "BOLL:${format(data.mb!)}    ",
                style: getTextStyle(chartColors.ma5Color)),
          if (data.up != 0)
            TextSpan(
                text: "UP:${format(data.up!)}    ",
                style: getTextStyle(chartColors.ma10Color)),
          if (data.dn != 0)
            TextSpan(
                text: "LB:${format(data.dn!)}    ",
                style: getTextStyle(chartColors.ma30Color)),
        ],
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  List<InlineSpan> _createMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    if (data.maValueList?.length == 5) {
      List<Color> listColors = [
        chartColors.ma5Color,
        chartColors.ma10Color,
        chartColors.ma30Color,
        chartColors.ma30Color,
        chartColors.ma30Color,
      ];
      for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
        if (data.maValueList?[i] != 0) {
          var item = TextSpan(
              text: "MA(${maDayList[i]}):${format(data.maValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.maValueList?.length == 4) {
      List<Color> listColors = [
        chartColors.ma5Color,
        chartColors.ma10Color,
        chartColors.ma30Color,
        chartColors.ma40Color,
      ];
      for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
        if (data.maValueList?[i] != 0) {
          var item = TextSpan(
              text: "MA(${maDayList[i]}):${format(data.maValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.maValueList?.length == 3) {
      List<Color> listColors = [
        chartColors.ma5Color,
        chartColors.ma10Color,
        chartColors.ma30Color,
      ];
      for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
        if (data.maValueList?[i] != 0) {
          var item = TextSpan(
              text: "MA(${maDayList[i]}):${format(data.maValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.maValueList?.length == 2) {
      List<Color> listColors = [
        chartColors.ma5Color,
        chartColors.ma10Color,
      ];
      for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
        if (data.maValueList?[i] != 0) {
          var item = TextSpan(
              text: "MA(${maDayList[i]}):${format(data.maValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.maValueList?.length == 1) {
      List<Color> listColors = [
        chartColors.ma5Color,
      ];
      for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
        if (data.maValueList?[i] != 0) {
          var item = TextSpan(
              text: "MA(${maDayList[i]}):${format(data.maValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.maValueList?.length == 6) {
      List<Color> listColors = [
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
      ];
      for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
        if (data.maValueList?[i] != 0) {
          var item = TextSpan(
              text: "MA(${maDayList[i]}):${format(data.maValueList![i])} ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    }
    return result;
  }

  List<InlineSpan> _createEMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];

    if (data.emaValueList?.length == 1) {
      List<Color> listColors = [
        chartColors.ema5Color,
      ];
      for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
        if (data.emaValueList?[i] != 0) {
          var item = TextSpan(
              text:
                  "EMA(${emaDayList[i]}):${format(data.emaValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.emaValueList?.length == 2) {
      List<Color> listColors = [
        chartColors.ema5Color,
        chartColors.ema10Color,
      ];
      for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
        if (data.emaValueList?[i] != 0) {
          var item = TextSpan(
              text:
                  "EMA(${emaDayList[i]}):${format(data.emaValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.emaValueList?.length == 3) {
      List<Color> listColors = [
        chartColors.ema5Color,
        chartColors.ema10Color,
        chartColors.ema30Color,
      ];
      for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
        if (data.emaValueList?[i] != 0) {
          var item = TextSpan(
              text:
                  "EMA(${emaDayList[i]}):${format(data.emaValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.emaValueList?.length == 4) {
      List<Color> listColors = [
        chartColors.ema5Color,
        chartColors.ema10Color,
        chartColors.ema30Color,
        chartColors.ema40Color,
      ];
      for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
        if (data.emaValueList?[i] != 0) {
          var item = TextSpan(
              text:
                  "EMA(${emaDayList[i]}):${format(data.emaValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.emaValueList?.length == 5) {
      List<Color> listColors = [
        chartColors.ema5Color,
        chartColors.ema10Color,
        chartColors.ema30Color,
        chartColors.ema40Color,
        chartColors.ema50Color,
      ];
      for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
        if (data.emaValueList?[i] != 0) {
          var item = TextSpan(
              text:
                  "EMA(${emaDayList[i]}):${format(data.emaValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    } else if (data.emaValueList?.length == 6) {
      List<Color> listColors = [
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
      ];
      for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
        if (data.emaValueList?[i] != 0) {
          var item = TextSpan(
              text:
                  "EMA(${emaDayList[i]}):${format(data.emaValueList![i])}    ",
              style: getTextStyle(listColors[i]));
          result.add(item);
        }
      }
      return result;
    }

    return result;
  }

  @override
  void drawChart(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas,List<double> strokes) {
    if (isLine != true) drawCandle(curPoint, canvas, curX);
    if (isLine == true) {
      draLine(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else if (state == MainState.MA) {
      drawMaLine(lastPoint, curPoint, canvas, lastX, curX,strokes);
    } else if (state == MainState.EMA) {
      drawEMaLine(lastPoint, curPoint, canvas, lastX, curX,strokes);
    } else if (state == MainState.BOLL) {
      drawBollLine(lastPoint, curPoint, canvas, lastX, curX,strokes);
    }
  }

  //画折线图
  draLine(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
    Shader? mLineFillShader;
    Path? mLinePath, mLineFillPath;
    final double mLineStrokeWidth = 1.0;
    final Paint mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = chartColors.kLineColor;
    final Paint mLineFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    mLinePath ??= Path();

    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath.moveTo(lastX, getY(lastPrice));
    mLinePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

//    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: chartColors.kLineShadowColor,
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath.lineTo(lastX, getY(lastPrice));
    mLineFillPath.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath.close();

    canvas.drawPath(mLineFillPath, mLineFillPaint);
    mLineFillPath.reset();

    canvas.drawPath(mLinePath,
        mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.3, 1.0));
    mLinePath.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX,List<double> strokes) {
    switch (curPoint.maValueList?.length) {
      case 6:
        for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
          if (lastPoint.maValueList?[i] != 0) {
            drawLine(
                lastPoint.maValueList![i],
                curPoint.maValueList![i],
                canvas,
                lastX,
                curX,
                [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                ][i], strokes[i]);
          }
        }
        break;
      case 5:
        for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
          if (lastPoint.maValueList?[i] != 0) {
            drawLine(
                lastPoint.maValueList![i],
                curPoint.maValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ma5Color,
                  chartColors.ma10Color,
                  chartColors.ma30Color,
                  chartColors.ma40Color,
                  chartColors.ma50Color
                ][i],strokes[i]);
          }
        }
        break;
      case 4:
        for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
          if (lastPoint.maValueList?[i] != 0) {
            drawLine(
                lastPoint.maValueList![i],
                curPoint.maValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ma5Color,
                  chartColors.ma10Color,
                  chartColors.ma30Color,
                  chartColors.ma40Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 3:
        for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
          if (lastPoint.maValueList?[i] != 0) {
            drawLine(
                lastPoint.maValueList![i],
                curPoint.maValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ma5Color,
                  chartColors.ma10Color,
                  chartColors.ma30Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 2:
        for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
          if (lastPoint.maValueList?[i] != 0) {
            drawLine(
                lastPoint.maValueList![i],
                curPoint.maValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ma5Color,
                  chartColors.ma10Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 1:
        for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
          if (lastPoint.maValueList?[i] != 0) {
            drawLine(
                lastPoint.maValueList![i],
                curPoint.maValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ma5Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 0:
        drawLine(
          46042.85600000001,
          43711.47200000001,
          canvas,
          247.5,
          258.5,
          Colors.transparent,0.5
        );

        break;
    }
  }

  void drawEMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX,List<double> strokes) {
    switch (curPoint.emaValueList?.length) {
      case 1:
        for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
          if (lastPoint.emaValueList?[i] != 0) {
            drawLine(
                lastPoint.emaValueList![i],
                curPoint.emaValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ema5Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 2:
        for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
          if (lastPoint.emaValueList?[i] != 0) {
            drawLine(
                lastPoint.emaValueList![i],
                curPoint.emaValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ema5Color,
                  chartColors.ema10Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 3:
        for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
          if (lastPoint.emaValueList?[i] != 0) {
            drawLine(
                lastPoint.emaValueList![i],
                curPoint.emaValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ema5Color,
                  chartColors.ema10Color,
                  chartColors.ema30Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 4:
        for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
          if (lastPoint.emaValueList?[i] != 0) {
            drawLine(
                lastPoint.emaValueList![i],
                curPoint.emaValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ema5Color,
                  chartColors.ema10Color,
                  chartColors.ema30Color,
                  chartColors.ema40Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 5:
        for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
          if (lastPoint.emaValueList?[i] != 0) {
            drawLine(
                lastPoint.emaValueList![i],
                curPoint.emaValueList![i],
                canvas,
                lastX,
                curX,
                [
                  chartColors.ema5Color,
                  chartColors.ema10Color,
                  chartColors.ema30Color,
                  chartColors.ema40Color,
                  chartColors.ema50Color,
                ][i],strokes[i]);
          }
        }
        break;
      case 6:
        for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
          if (lastPoint.emaValueList?[i] != 0) {
            drawLine(
                lastPoint.emaValueList![i],
                curPoint.emaValueList![i],
                canvas,
                lastX,
                curX,
                [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                ][i],strokes[i]);
          }
        }
        break;
    }
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX,List<double> strokes) {
    if (lastPoint.up != 0) {
      drawLine(lastPoint.up!, curPoint.up!, canvas, lastX, curX,
          chartColors.bollFirstColor, strokes[0]);
    }
    if (lastPoint.mb != 0) {
      drawLine(lastPoint.mb!, curPoint.mb!, canvas, lastX, curX,
          chartColors.bollFirstColor, strokes[1]);
    }
    if (lastPoint.dn != 0) {
      drawLine(lastPoint.dn!, curPoint.dn!, canvas, lastX, curX,
          chartColors.bollThirdColor, strokes[2]);
    }
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;

    //防止线太细，强制最细1px
    if ((open - close).abs() < 1) {
      if (open > close) {
        open += 0.5;
        close -= 0.5;
      } else {
        open -= 0.5;
        close += 0.5;
      }
    }
    if (open > close) {
      chartPaint.color = chartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else {
      chartPaint.color = chartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    }
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double position = 0;
      if (i == 0) {
        position = (gridRows - i) * rowSpace - _contentPadding / 2;
      } else if (i == gridRows) {
        position = (gridRows - i) * rowSpace + _contentPadding / 2;
      } else {
        position = (gridRows - i) * rowSpace;
      }
      var value = position / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      double y;
      if (i == 0 || i == gridRows) {
        y = getY(value) - tp.height / 2;
      } else {
        y = getY(value) - tp.height;
      }
      tp.paint(canvas, Offset(chartRect.width - tp.width, y));
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, topPadding / 3),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
