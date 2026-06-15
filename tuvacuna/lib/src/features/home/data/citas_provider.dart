import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_controller.dart';
import '../../../core/models/cita.dart';
import '../../../core/models/notificacion.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/app_user.dart';
import '../../../core/models/controlador_vacunacion.dart';

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
    
    // Factory Method para notificación
    CreadorNotificacion creador = CreadorNotifEmail(); // Opcionalmente usar CreadorNotifSMS
    INotificacion notificacion = creador.crearNotificacion();
    String msg = 'Tu cita para el ${cita.fecha.day}/${cita.fecha.month}/${cita.fecha.year} a las ${cita.hora} ha sido agendada con éxito.';
    
    // Llamamos a enviar()
    notificacion.enviar(msg, cita.paciente);
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

    // Factory Method para notificación
    CreadorNotificacion creador = CreadorNotifSMS(); // Variamos a SMS para este caso
    INotificacion notificacion = creador.crearNotificacion();
    String msg = 'La cita para el ${newCita.fecha.day}/${newCita.fecha.month}/${newCita.fecha.year} a las ${newCita.hora} ha sido actualizada.';
    
    // Llamamos a enviar()
    notificacion.enviar(msg, newCita.paciente);
    db.addNotificacion(notificacion);

    // Llamar adaptador si la cita es completada
    if (newCita.estadoCita == 'Completa' && oldCita.estadoCita != 'Completa') {
      final vacuna = newCita.vacunacion?.vacunaAplicada;
      if (vacuna != null) {
        final adaptador = AdaptadorMinsal();
        final controlador = ControladorVacunacion(adaptador);
        controlador.registrarDosis(newCita.paciente.rut, vacuna.id);
      }
    }
    
    final currentUser = ref.read(authStateProvider);

    if (currentUser == null) {
      state = [];
      return;
    }

    if (currentUser.role == AppRole.especialista) {
      state = db.getCitas
          .where((c) => c.especialista.rut == currentUser.rut)
          .toList();
    } else {
      state = db.getCitas
          .where((c) => c.paciente.rut == currentUser.rut)
          .toList();
    }
  }
}

final citasProvider = NotifierProvider<CitasNotifier, List<Cita>>(() {
  return CitasNotifier();
});
