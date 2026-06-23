import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/debt_manager/debt_manager_cubit.dart';
import '../blocs/debt_manager/debt_manager_state.dart';
import '../models/debt.dart';
import '../services/debt_repository.dart';
import '../widgets/amount_badge.dart';
import '../widgets/debt_card.dart';
import '../widgets/empty_state.dart';
import 'add_debt_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DebtManagerCubit>().selectPerson(widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de persona'),
        actions: [
          BlocBuilder<DebtManagerCubit, DebtManagerState>(
            builder: (context, state) {
              final person = state.selectedPerson;
              if (person == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDeletePerson(context, person.name),
                tooltip: 'Eliminar persona',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DebtManagerCubit, DebtManagerState>(
        builder: (context, state) {
          final person = state.selectedPerson;
          if (person == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final balance = context.read<DebtRepository>().balanceForPerson(
            person.id,
          );
          final isIncoming = balance > 0;
          final isZero = balance == 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isZero
                                ? 'Sin deudas activas'
                                : isIncoming
                                ? 'Me debe'
                                : 'Le debo',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          AmountBadge(
                            amount: balance.abs(),
                            isIncoming: isIncoming,
                            textStyle: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Deudas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: state.selectedPersonDebts.isEmpty
                    ? const EmptyState(
                        message:
                            'No hay deudas registradas.\nPresiona + para agregar una.',
                      )
                    : ListView.builder(
                        itemCount: state.selectedPersonDebts.length,
                        itemBuilder: (context, index) {
                          final debt = state.selectedPersonDebts[index];
                          return DebtCard(
                            debt: debt,
                            onTogglePaid: () => context
                                .read<DebtManagerCubit>()
                                .toggleDebtPaid(debt),
                            onEdit: () => _editDebt(context, debt),
                            onDelete: () => _confirmDeleteDebt(context, debt),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDebt(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar deuda'),
      ),
    );
  }

  void _addDebt(BuildContext context) async {
    final state = context.read<DebtManagerCubit>().state;
    final person = state.selectedPerson;
    if (person == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddDebtScreen(personId: person.id, personName: person.name),
      ),
    );
  }

  void _editDebt(BuildContext context, Debt debt) async {
    final state = context.read<DebtManagerCubit>().state;
    final person = state.selectedPerson;
    if (person == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddDebtScreen(
          personId: person.id,
          personName: person.name,
          debtToEdit: debt,
        ),
      ),
    );
  }

  void _confirmDeleteDebt(BuildContext context, debt) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar deuda'),
        content: const Text('¿Eliminar esta deuda permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DebtManagerCubit>().deleteDebt(debt);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePerson(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text('¿Eliminar a $name y todas sus deudas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DebtManagerCubit>().deletePerson(widget.personId);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
