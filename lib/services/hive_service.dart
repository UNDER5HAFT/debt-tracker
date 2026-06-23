import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/debt.dart';
import '../models/debt_type.dart';
import '../models/person.dart';

class HiveService {
  static const String peopleBoxName = 'people';
  static const String debtsBoxName = 'debts';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    _registerAdapters();
    await Hive.openBox<Person>(peopleBoxName);
    await Hive.openBox<Debt>(debtsBoxName);
    await Hive.openBox<bool>(settingsBoxName);
  }

  static void _registerAdapters() {
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(DebtAdapter());
    Hive.registerAdapter(DebtTypeAdapter());
  }

  static Box<Person> get peopleBox => Hive.box<Person>(peopleBoxName);
  static Box<Debt> get debtsBox => Hive.box<Debt>(debtsBoxName);
  static Box<bool> get settingsBox => Hive.box<bool>(settingsBoxName);
}
