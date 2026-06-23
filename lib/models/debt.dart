import 'package:hive/hive.dart';
import 'debt_type.dart';

class Debt extends HiveObject {
  Debt({
    required this.id,
    required this.personId,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.dueDate,
    this.isPaid = false,
  });

  String id;
  String personId;
  String description;
  double amount;
  DateTime date;
  DebtType type;
  DateTime? dueDate;
  bool isPaid;

  Debt copyWith({
    String? id,
    String? personId,
    String? description,
    double? amount,
    DateTime? date,
    DebtType? type,
    DateTime? dueDate,
    bool? isPaid,
  }) {
    return Debt(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 1;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String,
      personId: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime,
      type: fields[5] as DebtType,
      dueDate: fields[6] as DateTime?,
      isPaid: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personId)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.isPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
