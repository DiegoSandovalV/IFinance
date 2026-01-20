import 'package:drift/drift.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../domain/entities/tag.dart' as domain;
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase database;

  ExpenseRepositoryImpl(this.database);

  @override
  Future<void> addExpense(domain.Expense expense) async {
    await database.transaction(() async {
      await database.into(database.expenses).insert(
            ExpensesCompanion(
              id: Value(expense.id),
              amount: Value(expense.amount),
              date: Value(expense.date),
              description: Value(expense.description),
            ),
          );

      for (final tagId in expense.tagIds) {
        await database.into(database.expenseTags).insert(
              ExpenseTagsCompanion(
                expenseId: Value(expense.id),
                tagId: Value(tagId),
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteExpense(String id) async {
    await database.transaction(() async {
      await (database.delete(database.expenseTags)
            ..where((t) => t.expenseId.equals(id)))
          .go();
      await (database.delete(database.expenses)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }

  @override
  Future<List<domain.Expense>> getExpenses(
      {DateTime? startDate, DateTime? endDate}) async {
    final query = database.select(database.expenses);
    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    
    final expenses = <domain.Expense>[];
    for (final row in rows) {
      final tagRows = await (database.select(database.expenseTags)
            ..where((t) => t.expenseId.equals(row.id)))
          .get();
      
      expenses.add(domain.Expense(
        id: row.id,
        amount: row.amount,
        date: row.date,
        description: row.description,
        tagIds: tagRows.map((e) => e.tagId).toList(),
      ));
    }
    return expenses;
  }

  @override
  Stream<List<domain.Expense>> watchExpenses(
      {DateTime? startDate, DateTime? endDate}) {
    final query = database.select(database.expenses);
    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }

    return query.watch().asyncMap((rows) async {
      final expenses = <domain.Expense>[];
      for (final row in rows) {
        final tagRows = await (database.select(database.expenseTags)
              ..where((t) => t.expenseId.equals(row.id)))
            .get();

        expenses.add(domain.Expense(
          id: row.id,
          amount: row.amount,
          date: row.date,
          description: row.description,
          tagIds: tagRows.map((e) => e.tagId).toList(),
        ));
      }
      return expenses;
    });
  }

  @override
  Future<void> addTag(domain.Tag tag) async {
    await database.into(database.tags).insert(
      TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        budgetLimit: Value(tag.budgetLimit),
        budgetPeriod: Value(tag.budgetPeriod),
        colorValue: Value(tag.colorValue),
      ),
    );
  }

  @override
  Future<void> updateTag(domain.Tag tag) async {
    await database.update(database.tags).replace(
      TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        budgetLimit: Value(tag.budgetLimit),
        budgetPeriod: Value(tag.budgetPeriod),
        colorValue: Value(tag.colorValue),
      ),
    );
  }

  @override
  Future<void> deleteTag(String id) async {
     await (database.delete(database.tags)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<domain.Tag>> getTags() async {
    final rows = await database.select(database.tags).get();
    return rows.map((r) => domain.Tag(
      id: r.id,
      name: r.name,
      budgetLimit: r.budgetLimit,
      budgetPeriod: r.budgetPeriod,
      colorValue: r.colorValue,
    )).toList();
  }

  @override
  Stream<List<domain.Tag>> watchTags() {
    return database.select(database.tags).watch().map((rows) {
      return rows.map((r) => domain.Tag(
        id: r.id,
        name: r.name,
        budgetLimit: r.budgetLimit,
        budgetPeriod: r.budgetPeriod,
        colorValue: r.colorValue,
      )).toList();
    });
  }
}
  

