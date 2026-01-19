import '../entities/expense.dart';
import '../entities/tag.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate});
  Stream<List<Expense>> watchExpenses({DateTime? startDate, DateTime? endDate});

  Future<void> addTag(Tag tag);
  Future<void> updateTag(Tag tag);
  Future<void> deleteTag(String id);
  Future<List<Tag>> getTags();
  Stream<List<Tag>> watchTags();
}
