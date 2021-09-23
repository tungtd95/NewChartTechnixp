import 'package:technixo_k_chart/model/k_line_model/k_line_model.dart';
import 'package:technixo_k_chart/utils/n_interval.dart';

import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  double? amount;
  int? count;
  int? id;

  int? closeTime;
  int? startTime;
  NInterval? interval;
  double? takerBuyBaseVolume;
  double? takerBuyQuoteVolume;
  double? ignore;

  KLineEntity.fromHuobi(Map<String, dynamic> json) {
    open = (json['open'] as num).toDouble();
    high = (json['high'] as num).toDouble();
    low = (json['low'] as num).toDouble();
    close = (json['close'] as num).toDouble();
    vol = (json['vol'] as num).toDouble();
    amount = (json['amount'] as num?)?.toDouble();
    count = json['count'] as int?;
    id = json['id'] as int? ?? 0;
  }

  KLineEntity.fromBinance(dynamic data) {
    id = (data[0] as int) ~/ 1000;
    open = double.parse(data[1]);
    high = double.parse(data[2]);
    low = double.parse(data[3]);
    close = double.parse(data[4]);
    vol = double.parse(data[5]);
    closeTime = data[6] as int;
    startTime = id;
    amount = double.parse(data[7]);
    count = data[8] as int;
    takerBuyBaseVolume = double.parse(data[9]);
    takerBuyQuoteVolume = double.parse(data[10]);
    ignore = double.parse(data[11]);
  }

  KLineEntity.fromModel(KLineModel model) {
    id = model.t ~/ 1000;
    open = double.parse(model.o);
    high = double.parse(model.h);
    low = double.parse(model.l);
    close = double.parse(model.c);
    vol = double.parse(model.v);
    closeTime = model.T;
    startTime = id;
    interval = model.i.toNInterval;
    amount = double.parse(model.c);
    count = model.t;
    takerBuyBaseVolume = double.parse(model.V);
    takerBuyQuoteVolume = double.parse(model.Q);
    ignore = double.parse(model.B);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['count'] = this.count;
    data['interval'] = this.interval?.value;
    data['closeTime'] = this.closeTime;
    data['startTime'] = this.startTime;
    data['takerBuyBaseVolume'] = this.takerBuyBaseVolume;
    data['takerBuyQuoteVolume'] = this.takerBuyQuoteVolume;
    data['ignore'] = this.ignore;
    return data;
  }

  @override
  String toString() {
    return '${this.toJson()}';
  }
}
