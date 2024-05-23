class RealMoney {
  double second;
  double minute;
  double hour;
  double day;
  double month;
  double year;
  double untilNow;

  RealMoney({
    required this.second,
    required this.minute,
    required this.hour,
    required this.day,
    required this.month,
    required this.year,
    required this.untilNow,
  });

  Map<String, dynamic> toMap() {
    return {
      'second': second,
      'minute': minute,
      'hour': hour,
      'day': day,
      'month': month,
      'year': year,
      'untilNow': untilNow,
    };
  }
}
