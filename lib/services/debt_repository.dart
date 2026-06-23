import 'package:uuid/uuid.dart';

import '../models/debt.dart';
import '../models/debt_type.dart';
import '../models/person.dart';
import 'hive_service.dart';

class DebtRepository {
  final _peopleBox = HiveService.peopleBox;
  final _debtsBox = HiveService.debtsBox;
  final _uuid = const Uuid();

  List<Person> getAllPeople() => _peopleBox.values.toList();

  Person? getPersonById(String id) => _peopleBox.get(id);

  Future<Person> addPerson(String name) async {
    final person = Person(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await _peopleBox.put(person.id, person);
    return person;
  }

  Future<void> updatePerson(Person person) async {
    await _peopleBox.put(person.id, person);
  }

  Future<void> deletePerson(String id) async {
    await _peopleBox.delete(id);
    final debtsToDelete = _debtsBox.values
        .where((debt) => debt.personId == id)
        .map((debt) => debt.key)
        .toList();
    await _debtsBox.deleteAll(debtsToDelete);
  }

  List<Debt> getDebtsByPerson(String personId) =>
      _debtsBox.values.where((debt) => debt.personId == personId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  Future<Debt> addDebt({
    required String personId,
    required String description,
    required double amount,
    required DebtType type,
    DateTime? dueDate,
  }) async {
    final debt = Debt(
      id: _uuid.v4(),
      personId: personId,
      description: description.trim(),
      amount: amount,
      date: DateTime.now(),
      type: type,
      dueDate: dueDate,
    );
    await _debtsBox.put(debt.id, debt);

    final person = _peopleBox.get(personId);
    if (person != null) {
      person.lastDebtDate = DateTime.now();
      await person.save();
    }
    return debt;
  }

  Future<void> markDebtPaid(Debt debt) async {
    debt.isPaid = true;
    await debt.save();
  }

  Future<void> markDebtUnpaid(Debt debt) async {
    debt.isPaid = false;
    await debt.save();
  }

  Future<void> deleteDebt(Debt debt) async {
    await debt.delete();
  }

  Future<void> updateDebt(
    Debt debt, {
    String? description,
    double? amount,
    DebtType? type,
    DateTime? date,
    DateTime? dueDate,
  }) async {
    if (description != null) debt.description = description.trim();
    if (amount != null) debt.amount = amount;
    if (type != null) debt.type = type;
    if (date != null) debt.date = date;
    debt.dueDate = dueDate;
    await debt.save();
  }

  double balanceForPerson(String personId) {
    return getDebtsByPerson(
      personId,
    ).where((debt) => !debt.isPaid).fold<double>(0, (sum, debt) {
      final signedAmount = debt.type == DebtType.theyOweMe
          ? debt.amount
          : -debt.amount;
      return sum + signedAmount;
    });
  }

  double get totalTheyOweMe {
    double total = 0;
    for (final person in getAllPeople()) {
      final balance = balanceForPerson(person.id);
      if (balance > 0) {
        total += balance;
      }
    }
    return total;
  }

  double get totalIOweThem {
    double total = 0;
    for (final person in getAllPeople()) {
      final balance = balanceForPerson(person.id);
      if (balance < 0) {
        total += balance.abs();
      }
    }
    return total;
  }

  List<Person> getSortedPeople({String searchQuery = ''}) {
    final people = getAllPeople();
    final filtered = searchQuery.isEmpty
        ? people
        : people
              .where(
                (p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();

    filtered.sort((a, b) {
      final balanceA = balanceForPerson(a.id);
      final balanceB = balanceForPerson(b.id);
      final aIsZero = balanceA == 0;
      final bIsZero = balanceB == 0;

      if (aIsZero && !bIsZero) return 1;
      if (!aIsZero && bIsZero) return -1;
      if (aIsZero && bIsZero) {
        return b.createdAt.compareTo(a.createdAt);
      }

      final dateA = a.lastDebtDate ?? a.createdAt;
      final dateB = b.lastDebtDate ?? b.createdAt;
      return dateB.compareTo(dateA);
    });

    return filtered;
  }
}
