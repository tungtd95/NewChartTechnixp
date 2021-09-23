enum NInterval {
  m_1,
  m_3,
  m_5,
  m_15,
  m_30,
  h_1,
  h_2,
  h_4,
  h_6,
  h_8,
  h_12,
  d_1,
  d_3,
  w_1,
  M_1,
}

enum MainState { MA, EMA, BOLL, NONE }

enum SecondaryState { MACD, KDJ, RSI, WR, CCI, NONE }

extension IntervalExt on NInterval {
  String get value => toString().split('.').last.split('_').reversed.join();
}

extension MainStateExt on MainState {
  String get str => toString().split('.').last;
}

extension SecondaryStateExt on SecondaryState {
  String get str => toString().split('.').last;
}

extension StringExt on String {
  MainState get toMainState => this == MainState.NONE.str
      ? MainState.NONE
      : (this == MainState.MA.str
          ? MainState.MA
          : (this == MainState.BOLL.str)
              ? MainState.BOLL
              : MainState.NONE);

  SecondaryState get toSecondaryState => this == SecondaryState.NONE.str
      ? SecondaryState.NONE
      : (this == SecondaryState.MACD.str
          ? SecondaryState.MACD
          : (this == SecondaryState.KDJ.str)
              ? SecondaryState.KDJ
              : (this == SecondaryState.WR.str)
                  ? SecondaryState.WR
                  : (this == SecondaryState.CCI.str)
                      ? SecondaryState.CCI
                      : SecondaryState.NONE);

  NInterval get toNInterval {
    switch (this) {
      case '1m':
        return NInterval.m_1;
      case '3m':
        return NInterval.m_3;
      case '5m':
        return NInterval.m_5;
      case '15m':
        return NInterval.m_15;
      case '30m':
        return NInterval.m_30;
      case '1h':
        return NInterval.h_1;
      case '2h':
        return NInterval.h_2;
      case '4h':
        return NInterval.h_4;
      case '6h':
        return NInterval.h_6;
      case '8h':
        return NInterval.h_8;
      case '12h':
        return NInterval.h_12;
      case '1d':
        return NInterval.d_1;
      case '3d':
        return NInterval.d_3;
      case '1w':
        return NInterval.w_1;
      case '1M':
        return NInterval.M_1;
    }
    return NInterval.m_1;
  }
}
