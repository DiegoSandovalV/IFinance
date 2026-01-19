import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<List<Expense>> call({DateTime? startDate, DateTime? endDate}) {
    return repository.getExpenses(startDate: startDate, endDate: endDate);
  }

  Stream<List<Expense>> watch({DateTime? startDate, DateTime? endDate}) {
    return repository.watchExpenses(startDate: startDate, endDate: endDate);
  }
}
