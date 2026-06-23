import 'package:debt_manager/blocs/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/debt_manager/debt_manager_cubit.dart';
import '../blocs/debt_manager/debt_manager_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../services/debt_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/person_card.dart';
import '../widgets/summary_card.dart';
import 'add_person_screen.dart';
import 'person_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DebtManagerCubit>().loadPeople();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Deudas'),
        centerTitle: true,
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                tooltip: 'Cambiar tema',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<DebtManagerCubit, DebtManagerState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              SummaryCard(
                totalTheyOweMe: state.totalTheyOweMe,
                totalIOweThem: state.totalIOweThem,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar persona...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) =>
                      context.read<DebtManagerCubit>().search(value),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: state.people.isEmpty
                    ? EmptyState(
                        message: state.searchQuery.isEmpty
                            ? 'No hay personas registradas.\nPresiona + para agregar una.'
                            : 'No se encontraron personas con "$state.searchQuery"',
                      )
                    : ListView.builder(
                        itemCount: state.people.length,
                        itemBuilder: (context, index) {
                          final person = state.people[index];
                          final balance = context
                              .read<DebtRepository>()
                              .balanceForPerson(person.id);
                          return PersonCard(
                            person: person,
                            balance: balance,
                            onTap: () => _openPersonDetail(context, person.id),
                            onDelete: () =>
                                _confirmDeletePerson(context, person),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPerson(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar persona'),
      ),
    );
  }

  void _addPerson(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddPersonScreen()));
  }

  void _openPersonDetail(BuildContext context, String personId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PersonDetailScreen(personId: personId)),
    );
  }

  void _confirmDeletePerson(BuildContext context, person) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text('¿Eliminar a ${person.name} y todas sus deudas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DebtManagerCubit>().deletePerson(person.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
