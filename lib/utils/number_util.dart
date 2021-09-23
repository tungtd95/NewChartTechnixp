import 'dart:math';

class NumberUtil {
  static String volFormat(double n) {
    if (n > 10000 && n < 999999) {
      double d = n / 1000;
      return "${d.toStringAsFixed(2)}K";
    } else if (n > 1000000) {
      double d = n / 1000000;
      return "${d.toStringAsFixed(2)}M";
    }
    return n.toStringAsFixed(2);
  }

  //保留多少位小数
  static int _fractionDigits = 2;

  static set fractionDigits(int value) {
    if (value != _fractionDigits) _fractionDigits = value;
  }

  static String format(double price) {
    return price.toStringAsFixed(_fractionDigits);
  }

  static int getMaxDecimalLength(double a, double b, double c, double d) {
    int result = max(_getDecimalLength(a), _getDecimalLength(b));
    result = max(result, _getDecimalLength(c));
    result = max(result, _getDecimalLength(d));
    return result;
  }

  static int _getDecimalLength(double b) {
    String s = b.toString();
    int dotIndex = s.indexOf(".");
    if (dotIndex < 0) {
      return 0;
    } else {
      return s.length - dotIndex - 1;
    }
  }
}
