import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/core/data/database_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbController = DatabaseController();
  await dbController.initDatabase();

  runApp(
    ProviderScope(
      overrides: [
        databaseControllerProvider.overrideWithValue(dbController),
      ],
      child: const MyApp(),
    ),
  );
}
