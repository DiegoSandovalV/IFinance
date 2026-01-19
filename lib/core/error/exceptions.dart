class ExpenseLimitExceededException implements Exception {
  final String message;
  ExpenseLimitExceededException([this.message = 'Expense limit exceeded']);

  @override
  String toString() => 'ExpenseLimitExceededException: $message';
}
