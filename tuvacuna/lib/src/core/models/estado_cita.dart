import 'package:tuvacuna/src/core/models/vacunacion.dart';

abstract class EstadoCita {
  void confirmar();
  void registrarVacunacion(Vacunacion v);
  void cancelar();
  String name();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is EstadoCita) return name() == other.name();
    if (other is String) return name() == other;
    return false;
  }

  @override
  int get hashCode => name().hashCode;

  @override
  String toString() => name();
}
