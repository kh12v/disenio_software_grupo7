import 'package:tuvacuna/src/core/models/estado_cita.dart';
import 'package:tuvacuna/src/core/models/cita.dart';
import 'package:tuvacuna/src/core/models/estado_cancelada.dart';
import 'package:tuvacuna/src/core/models/vacunacion.dart';


class EstadoConfirmada implements EstadoCita {
	EstadoConfirmada(this._cita);
	final Cita _cita;

	@override
	void cancelar() {
		_cita.estadoCita = EstadoCancelada(_cita);
	}

	@override
	void confirmar() {
		// ya confirmada
	}

	@override
	void registrarVacunacion(Vacunacion v) {
		_cita.vacunacion = v;
	}

	@override
	String name() => 'Completa';
}
