import 'package:equatable/equatable.dart';

import '../../models/debt.dart';
import '../../models/person.dart';

class DebtManagerState extends Equatable {
  final List<Person> people;
  final List<Debt> selectedPersonDebts;
  final Person? selectedPerson;
  final String searchQuery;
  final double totalTheyOweMe;
  final double totalIOweThem;
  final bool isLoading;
  final String? errorMessage;

  const DebtManagerState({
    this.people = const [],
    this.selectedPersonDebts = const [],
    this.selectedPerson,
    this.searchQuery = '',
    this.totalTheyOweMe = 0,
    this.totalIOweThem = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  DebtManagerState copyWith({
    List<Person>? people,
    List<Debt>? selectedPersonDebts,
    Person? selectedPerson,
    String? searchQuery,
    double? totalTheyOweMe,
    double? totalIOweThem,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DebtManagerState(
      people: people ?? this.people,
      selectedPersonDebts: selectedPersonDebts ?? this.selectedPersonDebts,
      selectedPerson: selectedPerson ?? this.selectedPerson,
      searchQuery: searchQuery ?? this.searchQuery,
      totalTheyOweMe: totalTheyOweMe ?? this.totalTheyOweMe,
      totalIOweThem: totalIOweThem ?? this.totalIOweThem,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        people,
        selectedPersonDebts,
        selectedPerson,
        searchQuery,
        totalTheyOweMe,
        totalIOweThem,
        isLoading,
        errorMessage,
      ];
}
