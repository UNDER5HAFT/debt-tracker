import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/debt.dart';
import '../../models/debt_type.dart';
import '../../services/debt_repository.dart';
import 'debt_manager_state.dart';

class DebtManagerCubit extends Cubit<DebtManagerState> {
  final DebtRepository _repository;

  DebtManagerCubit(this._repository) : super(const DebtManagerState());

  Future<void> loadPeople({String searchQuery = ''}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final people = _repository.getSortedPeople(searchQuery: searchQuery);
      emit(
        state.copyWith(
          people: people,
          searchQuery: searchQuery,
          totalTheyOweMe: _repository.totalTheyOweMe,
          totalIOweThem: _repository.totalIOweThem,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error al cargar personas: $e',
        ),
      );
    }
  }

  Future<void> search(String query) async {
    await loadPeople(searchQuery: query);
  }

  Future<void> addPerson(String name) async {
    try {
      if (name.trim().isEmpty) {
        emit(state.copyWith(errorMessage: 'El nombre no puede estar vacío'));
        return;
      }
      await _repository.addPerson(name);
      await loadPeople(searchQuery: state.searchQuery);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al agregar persona: $e'));
    }
  }

  Future<void> deletePerson(String id) async {
    try {
      await _repository.deletePerson(id);
      if (state.selectedPerson?.id == id) {
        emit(
          state.copyWith(selectedPerson: null, selectedPersonDebts: const []),
        );
      }
      await loadPeople(searchQuery: state.searchQuery);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al eliminar persona: $e'));
    }
  }

  Future<void> selectPerson(String personId) async {
    final person = _repository.getPersonById(personId);
    if (person == null) return;
    final debts = _repository.getDebtsByPerson(personId);
    emit(state.copyWith(selectedPerson: person, selectedPersonDebts: debts));
  }

  Future<void> clearSelectedPerson() async {
    emit(state.copyWith(selectedPerson: null, selectedPersonDebts: const []));
  }

  Future<void> addDebt({
    required String personId,
    required String description,
    required double amount,
    required DebtType type,
    DateTime? dueDate,
  }) async {
    try {
      if (description.trim().isEmpty) {
        emit(
          state.copyWith(errorMessage: 'La descripción no puede estar vacía'),
        );
        return;
      }
      if (amount <= 0) {
        emit(state.copyWith(errorMessage: 'La cantidad debe ser mayor a 0'));
        return;
      }
      await _repository.addDebt(
        personId: personId,
        description: description,
        amount: amount,
        type: type,
        dueDate: dueDate,
      );
      await selectPerson(personId);
      await loadPeople(searchQuery: state.searchQuery);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al agregar deuda: $e'));
    }
  }

  Future<void> editDebt({
    required Debt debt,
    required String description,
    required double amount,
    required DebtType type,
    required DateTime date,
    DateTime? dueDate,
  }) async {
    try {
      if (description.trim().isEmpty) {
        emit(
          state.copyWith(errorMessage: 'La descripción no puede estar vacía'),
        );
        return;
      }
      if (amount <= 0) {
        emit(state.copyWith(errorMessage: 'La cantidad debe ser mayor a 0'));
        return;
      }
      await _repository.updateDebt(
        debt,
        description: description,
        amount: amount,
        type: type,
        date: date,
        dueDate: dueDate,
      );
      await selectPerson(debt.personId);
      await loadPeople(searchQuery: state.searchQuery);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al editar deuda: $e'));
    }
  }

  Future<void> toggleDebtPaid(Debt debt) async {
    try {
      if (debt.isPaid) {
        await _repository.markDebtUnpaid(debt);
      } else {
        await _repository.markDebtPaid(debt);
      }
      await selectPerson(debt.personId);
      await loadPeople(searchQuery: state.searchQuery);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al actualizar deuda: $e'));
    }
  }

  Future<void> deleteDebt(Debt debt) async {
    try {
      await _repository.deleteDebt(debt);
      await selectPerson(debt.personId);
      await loadPeople(searchQuery: state.searchQuery);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al eliminar deuda: $e'));
    }
  }
}
