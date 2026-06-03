import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_controller.dart';
import '../../../core/models/cita.dart';
import '../../../core/models/notificacion.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/app_user.dart';

class CitasNotifier extends Notifier<List<Cita>> {
  @override
  List<Cita> build() {
    final db = ref.watch(databaseControllerProvider);
    final currentUser = ref.watch(authStateProvider);
    
    if (currentUser == null) return [];

    if (currentUser.role == AppRole.especialista) {
      return db.getCitas.where((c) => c.especialista.rut == currentUser.rut).toList();
    }
    
    return db.getCitas.where((c) => c.paciente.rut == currentUser.rut).toList();
  }

  bool addCita(Cita cita) {
    final db = ref.read(databaseControllerProvider);
    if (!db.addCita(cita)) {
      return false;
    }
    
    // Crear notificación (Simulada)
    final notificacion = Notificacion(
      mensaje: 'Nueva cita agendada en ${cita.centroVacunacion.nombreCentro} para el ${cita.fecha.day}/${cita.fecha.month}/${cita.fecha.year} a las ${cita.hora}',
      canalEnvio: 'email',
      fechaEnvio: DateTime.now(),
    );
    db.addNotificacion(notificacion);
    
    // Forzamos actualización de estado
    state = [...state, cita];
    return true;
  }

  void updateCita(Cita oldCita, Cita newCita) {
    final db = ref.read(databaseControllerProvider);
    
    final index = db.citas.indexOf(oldCita);
    if (index != -1) {
      db.citas[index] = newCita;
    }
    
    final notificacion = Notificacion(
      mensaje: 'El estado de la cita ha cambiado a ${newCita.estadoCita}',
      canalEnvio: 'email',
      fechaEnvio: DateTime.now(),
    );
    db.addNotificacion(notificacion);
    
    final currentUser = ref.read(authStateProvider);
    if (currentUser?.role == AppRole.especialista) {
      state = db.getCitas.where((c) => c.especialista.rut == currentUser!.rut).toList();
    } else {
      state = db.getCitas.where((c) => c.paciente.rut == currentUser!.rut).toList();
    }
  }
}

final citasProvider = NotifierProvider<CitasNotifier, List<Cita>>(() {
  return CitasNotifier();
});
