import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';
import '../../../core/data/database_controller.dart';

class AuthRepository {
  final DatabaseController db;

  AuthRepository(this.db);

  /// Simulates a network request to a government API for authentication
  Future<AppUser?> login(String rut, String claveUnica) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (rut.trim().isEmpty || claveUnica.trim().isEmpty) {
      throw Exception('RUT y Clave Única son requeridos');
    }

    if (claveUnica != '1234') {
      throw Exception('Clave Única incorrecta (simulada)');
    }

    // Check if user is in "personas"
    final personas = db.getPersonas;
    final personaIndex = personas.indexWhere((p) => p.rut == rut);
    
    if (personaIndex == -1) {
      throw Exception('Usuario no encontrado en la base de datos de personas');
    }

    final persona = personas[personaIndex];

    // Determine role
    final isOrganizador = db.getOrganizadores.any((o) => o.rut == rut);
    if (isOrganizador) {
      return AppUser(rut: rut, name: '${persona.nombres} ${persona.apellidos}', role: AppRole.organizador);
    }

    final isEspecialista = db.getEspecialistas.any((e) => e.rut == rut);
    if (isEspecialista) {
      return AppUser(rut: rut, name: '${persona.nombres} ${persona.apellidos}', role: AppRole.especialista);
    }

    return AppUser(rut: rut, name: '${persona.nombres} ${persona.apellidos}', role: AppRole.paciente);
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(databaseControllerProvider);
  return AuthRepository(db);
});

// A provider to manage the currently logged-in user state
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  Future<void> login(String rut, String claveUnica) async {
    final authRepository = ref.read(authRepositoryProvider);
    final user = await authRepository.login(rut, claveUnica);
    state = user;
  }

  Future<void> logout() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.logout();
    state = null;
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AppUser?>(() {
  return AuthNotifier();
});
