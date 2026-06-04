import 'package:tuvacuna/src/core/models/estado_cita.dart';
import 'package:tuvacuna/src/core/models/cita.dart';
import 'package:tuvacuna/src/core/models/vacunacion.dart';

class EstadoCancelada implements EstadoCita {
  EstadoCancelada(Cita _);

  @override
  void cancelar() {
    // ya cancelada
  }

  @override
  void confirmar() {
    // no se puede confirmar una cancelada
  }

  @override
  void registrarVacunacion(Vacunacion v) {
    // no aplica
  }

  @override
  String name() => 'Cancelada';
}
