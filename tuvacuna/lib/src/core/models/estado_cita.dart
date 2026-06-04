import 'package:tuvacuna/src/core/models/vacunacion.dart';

abstract class EstadoCita {
  void confirmar();
  void registrarVacunacion(Vacunacion v);
  void cancelar();
  String name();

  @override
  String toString() => name();
}
