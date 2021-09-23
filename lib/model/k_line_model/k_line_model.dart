/// {
///     "e": "kline",     // Event type
///     "E": 123456789,   // Event time
///     "s": "BTCUSDT",    // Symbol
///     "k": {
///        "t": 123400000, // Kline start time
///        "T": 123460000, // Kline close time
///        "s": "BTCUSDT",  // Symbol
///        "i": "1m",      // Interval
///        "f": 100,       // First trade ID
///        "L": 200,       // Last trade ID
///        "o": "0.0010",  // Open price
///        "c": "0.0020",  // Close price
///        "h": "0.0025",  // High price
///        "l": "0.0015",  // Low price
///        "v": "1000",    // Base asset volume
///        "n": 100,       // Number of trades
///        "x": false,     // Is this kline closed?
///        "q": "1.0000",  // Quote asset volume
///        "V": "500",     // Taker buy base asset volume
///        "Q": "0.500",   // Taker buy quote asset volume
///        "B": "123456"   // Ignore
///   }
/// }
import 'package:freezed_annotation/freezed_annotation.dart';

part 'k_line_model.freezed.dart';
part 'k_line_model.g.dart';

@freezed
class KLineModel with _$KLineModel {
  factory KLineModel({
    required int t,
    required int T,
    required String s,
    required String i,
    required int f,
    required int L,
    required String o,
    required String c,
    required String h,
    required String l,
    required String v,
    required int n,
    required bool x,
    required String q,
    required String V,
    required String Q,
    required String B,
  }) = _KLineModel;

  factory KLineModel.fromJson(dynamic json) => _$KLineModelFromJson(json);
}
