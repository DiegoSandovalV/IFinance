import '../entities/tag.dart';
import '../repositories/expense_repository.dart';

class GetTags {
  final ExpenseRepository repository;

  GetTags(this.repository);

  Future<List<Tag>> call() async {
    return repository.getTags();
  }
}

class AddTag {
  final ExpenseRepository repository;

  AddTag(this.repository);

  Future<void> call(Tag tag) async {
    return repository.addTag(tag);
  }
}
