class Balance {
  String id;
  String title;
  double balance;
  String fromDate;
  int timesAYear;

  Balance({
    required this.id,
    required this.title,
    required this.balance,
    required this.fromDate,
    required this.timesAYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'balance': balance,
      'fromDate': fromDate,
      'timesAYear': timesAYear,
    };
  }
}
