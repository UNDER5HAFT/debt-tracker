import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/debt_manager/debt_manager_cubit.dart';
import '../models/debt.dart';
import '../models/debt_type.dart';

class AddDebtScreen extends StatefulWidget {
  final String personId;
  final String personName;
  final Debt? debtToEdit;

  const AddDebtScreen({
    super.key,
    required this.personId,
    required this.personName,
    this.debtToEdit,
  });

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late DebtType _type;
  late DateTime _date;
  DateTime? _dueDate;
  bool _includeDueDate = false;

  bool get _isEditing => widget.debtToEdit != null;

  @override
  void initState() {
    super.initState();
    final debt = widget.debtToEdit;
    if (debt != null) {
      _descriptionController.text = debt.description;
      _amountController.text = debt.amount.toString();
      _type = debt.type;
      _date = debt.date;
      _dueDate = debt.dueDate;
      _includeDueDate = debt.dueDate != null;
    } else {
      _type = DebtType.theyOweMe;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar deuda' : 'Deuda de ${widget.personName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej. Préstamo para cena',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  prefixText: r'$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cantidad es obligatoria';
                  }
                  final amount = double.tryParse(value.replaceAll(',', ''));
                  if (amount == null || amount <= 0) {
                    return 'Ingresa una cantidad válida mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Fecha de la deuda',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_formatDate(_date)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¿Quién debe a quién?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _includeDueDate,
                    onChanged: (value) {
                      setState(() {
                        _includeDueDate = value ?? false;
                      });
                    },
                  ),
                  Text(
                    'Agregar fecha límite',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              if (_includeDueDate) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha límite',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'Seleccionar fecha'
                          : _formatDate(_dueDate!),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Actualizar deuda' : 'Guardar deuda',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<DebtType>(
      segments: const [
        ButtonSegment(
          value: DebtType.theyOweMe,
          label: Text('Me deben'),
          icon: Icon(Icons.arrow_downward),
        ),
        ButtonSegment(
          value: DebtType.iOweThem,
          label: Text('Les debo'),
          icon: Icon(Icons.arrow_upward),
        ),
      ],
      selected: {_type},
      onSelectionChanged: (selected) {
        setState(() {
          _type = selected.first;
        });
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _date,
      firstDate: _date,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_includeDueDate && _dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una fecha límite')),
        );
        return;
      }

      final amount = double.parse(
        _amountController.text.replaceAll(',', ''),
      );

      final cubit = context.read<DebtManagerCubit>();
      if (_isEditing) {
        cubit.editDebt(
          debt: widget.debtToEdit!,
          description: _descriptionController.text,
          amount: amount,
          type: _type,
          date: _date,
          dueDate: _includeDueDate ? _dueDate : null,
        );
      } else {
        cubit.addDebt(
          personId: widget.personId,
          description: _descriptionController.text,
          amount: amount,
          type: _type,
          dueDate: _includeDueDate ? _dueDate : null,
        );
      }
      Navigator.of(context).pop();
    }
  }
}
