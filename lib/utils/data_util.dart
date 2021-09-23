import 'dart:math';

import '../entity/k_line_entity.dart';

class DataUtil {
  List<int> maDayList = const [5, 10, 20];
  List<int> emaDayList = const [5, 10, 20];
  int n = 20, k = 2;

  DataUtil._();

  static final DataUtil I = DataUtil._();

  factory DataUtil({
    List<int>? maDayList,
    List<int>? emaDayList,
    int? n,
    int? k,
  }) {
    if (maDayList != null) I.maDayList = maDayList;

    if (emaDayList != null) I.emaDayList = emaDayList;

    if (n != null) I.n = n;

    if (k != null) I.k = k;

    return I;
  }

  void calculate(List<KLineEntity> datas) {
    _calcMA(datas);
    _calcEMA(datas);
    _calcBOLL(datas, n, k);
    _calcVolumeMA(datas);
    _calcKDJ(datas);
    _calcMACD(datas);
    _calcRSI(datas);
    _calcWR(datas);
    _calcCCI(datas);
  }

  void _calcMA(List<KLineEntity> datas) {
    List<double> ma = List<double>.filled(maDayList.length, 0);

    if (datas.isNotEmpty) {
      for (int i = 0; i < datas.length; i++) {
        KLineEntity entity = datas[i];
        final closePrice = entity.close;
        entity.maValueList = List<double>.filled(maDayList.length, 0);

        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= datas[i - maDayList[j]].close;
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else {
            entity.maValueList?[j] = 0;
          }
        }
      }
    }
  }

  void _calcEMA(List<KLineEntity> datas) {
    double tempSum = 0;
    if (datas.isNotEmpty) {
      for (int i = 0; i < datas.length; i++) {
        KLineEntity entity = datas[i];
        KLineEntity lastEntity = entity;
        if (i > 0) {
          lastEntity = datas[i - 1];
        }
        final closePrice = entity.close;
        entity.emaValueList = List<double>.filled(emaDayList.length, 0);
        tempSum += closePrice;

        for (int j = 0; j < emaDayList.length; j++) {
          if (emaDayList.contains(i + 1) && emaDayList[j] == i + 1) {
            final sma = tempSum / emaDayList[j];
            entity.emaValueList?[j] = sma.abs();
          } else if (emaDayList[j] <= i) {
            final k = 2 / (emaDayList[j] + 1);
            final ema =
                entity.close * k + lastEntity.emaValueList![j] * (1 - k);
            entity.emaValueList?[j] = ema.abs();
          }
        }
      }
    }
  }

  void _calcBOLL(List<KLineEntity> datas, int n, int k) {
    _calcBOLLMA(n, datas);
    for (int i = 0; i < datas.length; i++) {
      KLineEntity entity = datas[i];
      if (i >= n) {
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = datas[j].close;
          double m = entity.BOLLMA!;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.mb = entity.BOLLMA!;
        entity.up = entity.mb! + k * md;
        entity.dn = entity.mb! - k * md;
      }
    }
  }

  void _calcBOLLMA(int day, List<KLineEntity> datas) {
    double ma = 0;
    for (int i = 0; i < datas.length; i++) {
      KLineEntity entity = datas[i];
      ma += entity.close;
      if (i == day - 1) {
        entity.BOLLMA = ma / day;
      } else if (i >= day) {
        ma -= datas[i - day].close;
        entity.BOLLMA = ma / day;
      } else {
        entity.BOLLMA = null;
      }
    }
  }

  void _calcMACD(List<KLineEntity> datas) {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (int i = 0; i < datas.length; i++) {
      KLineEntity entity = datas[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * 8 / 10 + dif * 2 / 10;
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
    }
  }

  void _calcVolumeMA(List<KLineEntity> datas) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    for (int i = 0; i < datas.length; i++) {
      KLineEntity entry = datas[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= datas[i - 5].vol;
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= datas[i - 10].vol;
        entry.MA10Volume = volumeMa10 / 10;
      } else {
        entry.MA10Volume = 0;
      }
    }
  }

  void _calcRSI(List<KLineEntity> datas) {
    double? rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < datas.length; i++) {
      KLineEntity entity = datas[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double Rmax = max(0, closePrice - datas[i - 1].close.toDouble());
        double RAbs = (closePrice - datas[i - 1].close.toDouble()).abs();

        rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
        rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < 13) rsi = null;
      if (rsi != null && rsi.isNaN) rsi = null;
      entity.rsi = rsi;
    }
  }

  void _calcKDJ(List<KLineEntity> datas) {
    double k = 0;
    double d = 0;
    for (int i = 0; i < datas.length; i++) {
      KLineEntity entity = datas[i];
      final double closePrice = entity.close;
      int startIndex = i - 13;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = double.minPositive;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, datas[index].high);
        min14 = min(min14, datas[index].low);
      }
      double rsv = 100 * (closePrice - min14) / (max14 - min14);
      if (rsv.isNaN) {
        rsv = 0;
      }
      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        k = (rsv + 2 * k) / 3;
        d = (k + 2 * d) / 3;
      }
      if (i < 13) {
        entity.k = null;
        entity.d = null;
        entity.j = null;
      } else if (i == 13 || i == 14) {
        entity.k = k;
        entity.d = null;
        entity.j = null;
      } else {
        entity.k = k;
        entity.d = d;
        entity.j = 3 * k - 2 * d;
      }
    }
  }

  //WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]
  void _calcWR(List<KLineEntity> datas) {
    double r;
    for (int i = 0; i < datas.length; i++) {
      KLineEntity entity = datas[i];
      int startIndex = i - 14;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = double.minPositive;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, datas[index].high);
        min14 = min(min14, datas[index].low);
      }
      if (i < 13) {
        entity.r = -10;
      } else {
        r = -100 * (max14 - datas[i].close) / (max14 - min14);
        if (r.isNaN) {
          entity.r = null;
        } else {
          entity.r = r;
        }
      }
    }
  }

  void _calcCCI(List<KLineEntity> datas) {
    final size = datas.length;
    final count = 14;
    for (int i = 0; i < size; i++) {
      final kline = datas[i];
      final tp = (kline.high + kline.low + kline.close) / 3;
      final start = max(0, i - count + 1);
      var amount = 0.0;
      var len = 0;
      for (int n = start; n <= i; n++) {
        amount += (datas[n].high + datas[n].low + datas[n].close) / 3;
        len++;
      }
      final ma = amount / len;
      amount = 0.0;
      for (int n = start; n <= i; n++) {
        amount +=
            (ma - (datas[n].high + datas[n].low + datas[n].close) / 3).abs();
      }
      final md = amount / len;
      kline.cci = ((tp - ma) / 0.015 / md);
      if (kline.cci!.isNaN) {
        kline.cci = 0.0;
      }
    }
  }
}
