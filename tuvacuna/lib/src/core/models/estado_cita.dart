import 'cita.dart';
import 'vacunacion.dart';

abstract class EstadoCita {
  String get nombre;
  void confirmar(Cita c);
  void registrarVacunacion(Cita c, Vacunacion v);
  void cancelar(Cita c);
}

class EstadoAgendada implements EstadoCita {
  @override
  String get nombre => 'Pendiente';

  @override
  void confirmar(Cita c) {
    print("La cita ya está agendada/confirmada.");
  }

  @override
  void registrarVacunacion(Cita c, Vacunacion v) {
    c.vacunacion = v;
    c.estadoActual = EstadoRealizada();
    print("Vacunación registrada. Estado cambiado a Realizada.");
  }

  @override
  void cancelar(Cita c) {
    c.estadoActual = EstadoCancelada();
    print("Cita cancelada exitosamente.");
  }
}

class EstadoRealizada implements EstadoCita {
  @override
  String get nombre => 'Completa';

  @override
  void confirmar(Cita c) {
    print("Error: La cita ya fue realizada.");
  }

  @override
  void registrarVacunacion(Cita c, Vacunacion v) {
    print("Error: La cita ya tiene una vacunación registrada.");
  }

  @override
  void cancelar(Cita c) {
    print("Error: No se puede cancelar una cita ya realizada.");
  }
}

class EstadoCancelada implements EstadoCita {
  @override
  String get nombre => 'Cancelada';

  @override
  void confirmar(Cita c) {
    print("Error: No se puede confirmar una cita cancelada.");
  }

  @override
  void registrarVacunacion(Cita c, Vacunacion v) {
    print("Error: No se puede registrar vacunación en una cita cancelada.");
  }

  @override
  void cancelar(Cita c) {
    print("La cita ya se encuentra cancelada.");
  }
}
