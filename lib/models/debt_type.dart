import 'package:hive/hive.dart';

enum DebtType {
  theyOweMe,
  iOweThem,
}

extension DebtTypeExtension on DebtType {
  String get label => this == DebtType.theyOweMe ? 'Me deben' : 'Les debo';

  bool get isIncoming => this == DebtType.theyOweMe;
}

class DebtTypeAdapter extends TypeAdapter<DebtType> {
  @override
  final int typeId = 2;

  @override
  DebtType read(BinaryReader reader) {
    return DebtType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, DebtType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
