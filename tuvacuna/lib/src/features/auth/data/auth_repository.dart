import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';
import '../../../core/data/database_controller.dart';

class AuthRepository {
  final DatabaseController db;

  AuthRepository(this.db);

  // Normaliza el RUT para comparar sin puntos, guion ni diferencias entre k/K.
  String _normalizarRut(String rut) {
    return rut
        .replaceAll(RegExp(r'[^0-9kK]'), '')
        .toUpperCase()
        .trim();
  }

  /// Simula una petición a una API del gobierno para autenticación.
  Future<AppUser?> login(String rut, String claveUnica) async {
    await Future.delayed(const Duration(seconds: 1));

    if (rut.trim().isEmpty || claveUnica.trim().isEmpty) {
      throw Exception('RUT y Clave Única son requeridos');
    }

    if (claveUnica != '1234') {
      throw Exception('Clave Única incorrecta (simulada)');
    }

    final rutNormalizado = _normalizarRut(rut);

    final personas = db.getPersonas;

    final personaIndex = personas.indexWhere(
      (p) => _normalizarRut(p.rut) == rutNormalizado,
    );

    if (personaIndex == -1) {
      throw Exception('Usuario no encontrado en la base de datos de personas');
    }

    final persona = personas[personaIndex];

    final isOrganizador = db.getOrganizadores.any(
      (o) => _normalizarRut(o.rut) == rutNormalizado,
    );

    if (isOrganizador) {
      return AppUser(
        rut: persona.rut,
        name: '${persona.nombres} ${persona.apellidos}',
        role: AppRole.organizador,
      );
    }

    final isEspecialista = db.getEspecialistas.any(
      (e) => _normalizarRut(e.rut) == rutNormalizado,
    );

    if (isEspecialista) {
      return AppUser(
        rut: persona.rut,
        name: '${persona.nombres} ${persona.apellidos}',
        role: AppRole.especialista,
      );
    }

    return AppUser(
      rut: persona.rut,
      name: '${persona.nombres} ${persona.apellidos}',
      role: AppRole.paciente,
    );
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

// Provider para manejar el usuario actualmente logueado
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