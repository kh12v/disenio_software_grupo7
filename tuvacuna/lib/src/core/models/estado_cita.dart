import 'cita.dart';
import 'vacunacion.dart';

/// PATRÓN DE DISEÑO: State
/// Interfaz EstadoCita: Interfaz principal del patrón State que define los comportamientos
/// posibles de una Cita en cualquier estado dado.
abstract class EstadoCita {
  String get nombre;
  void confirmar(Cita c);
  void registrarVacunacion(Cita c, Vacunacion v);
  void cancelar(Cita c);
}

/// PATRÓN DE DISEÑO: State
/// EstadoAgendada: Estado concreto que encapsula el comportamiento cuando la cita está agendada/pendiente.
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

/// PATRÓN DE DISEÑO: State
/// EstadoRealizada: Estado concreto que encapsula el comportamiento de una cita cuando ya ha sido completada.
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

/// PATRÓN DE DISEÑO: State
/// EstadoCancelada: Estado concreto que encapsula el comportamiento de una cita que fue cancelada.
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
