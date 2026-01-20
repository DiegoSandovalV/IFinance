import 'package:equatable/equatable.dart';

enum BudgetPeriod { weekly, monthly, yearly }

class Tag extends Equatable {
  final String id;
  final String name;
  final double? budgetLimit;
  final BudgetPeriod? budgetPeriod;
  final int colorValue;

  const Tag({
    required this.id,
    required this.name,
    this.budgetLimit,
    this.budgetPeriod,
    this.colorValue = 0xFF9E9E9E,
  });

  @override
  List<Object?> get props => [id, name, budgetLimit, budgetPeriod, colorValue];
}
