import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/tag.dart';

part 'local_data_source.g.dart';

class Expenses extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get budgetLimit => real().nullable()();
  IntColumn get budgetPeriod => intEnum<BudgetPeriod>().nullable()();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF9E9E9E))();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseTags extends Table {
  TextColumn get expenseId => text().references(Expenses, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {expenseId, tagId};
}

@DriftDatabase(tables: [Expenses, Tags, ExpenseTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tags, tags.colorValue);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
