abstract class IReporteMinsal {
  void reportarPaciente(String rut, int idVacuna);
}

class APIExternaMinsal {
  void enviarDatos(String rut, int idVacuna) {
    print("APIExternaMinsal: Datos enviados - RUT: $rut, Vacuna ID: $idVacuna");
  }
}

class AdaptadorMinsal implements IReporteMinsal {
  final APIExternaMinsal _apiExterna = APIExternaMinsal();

  @override
  void reportarPaciente(String rut, int idVacuna) {
    // Aquí el adaptador podría transformar o adaptar los datos si la API externa lo requiriera.
    // Por ahora, solo simula la llamada.
    _apiExterna.enviarDatos(rut, idVacuna);
  }
}

class ControladorVacunacion {
  final IReporteMinsal reporteMinsal;

  ControladorVacunacion(this.reporteMinsal);

  void registrarDosis(String rut, int idVacuna) {
    // Registrar dosis a nivel local (lógica omitida)
    print("ControladorVacunacion: Dosis registrada localmente.");
    
    // Llamar a la interfaz del Minsal para notificar al sistema externo
    reporteMinsal.reportarPaciente(rut, idVacuna);
  }
}
