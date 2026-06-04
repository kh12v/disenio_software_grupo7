import 'package:tuvacuna/src/core/models/cita.dart';
import 'package:tuvacuna/src/core/models/estado_cita.dart';
import 'package:tuvacuna/src/core/models/vacunacion.dart';
import 'package:tuvacuna/src/core/models/estado_cancelada.dart';
import 'package:tuvacuna/src/core/models/estado_confirmada.dart';

class EstadoAgendada implements EstadoCita {
  EstadoAgendada(this._cita);
  final Cita _cita;

  @override
  void cancelar() {
    _cita.estadoCita = EstadoCancelada(_cita);
  }

  @override
  void confirmar() {
    _cita.estadoCita = EstadoConfirmada(_cita);
  }

  @override
  void registrarVacunacion(Vacunacion v) {
    _cita.vacunacion = v;
    _cita.estadoCita = EstadoConfirmada(_cita);
  }

  @override
  String name() => 'Pendiente';
}
