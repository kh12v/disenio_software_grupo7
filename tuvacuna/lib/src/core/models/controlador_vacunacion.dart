/// PATRÓN DE DISEÑO: Adapter
/// IReporteMinsal: Interfaz requerida para notificar al Minsal.
/// Contiene el mensaje: reportarPaciente(rut, idVacuna).
abstract class IReporteMinsal {
  void reportarPaciente(String rut, int idVacuna);
}

/// PATRÓN DE DISEÑO: Adapter
/// APIExternaMinsal: La clase adaptada que simula un servicio externo con interfaz incompatible.
class APIExternaMinsal {
  void enviarDatos(String rut, int idVacuna) {
    print("APIExternaMinsal: Datos enviados - RUT: $rut, Vacuna ID: $idVacuna");
  }
}

/// PATRÓN DE DISEÑO: Adapter
/// AdaptadorMinsal: Clase Adapter que implementa la interfaz IReporteMinsal para traducir las
/// peticiones hacia el formato que requiere APIExternaMinsal.
class AdaptadorMinsal implements IReporteMinsal {
  final APIExternaMinsal _apiExterna = APIExternaMinsal();

  @override
  void reportarPaciente(String rut, int idVacuna) {
    // Aquí el adaptador podría transformar o adaptar los datos si la API externa lo requiriera.
    // Por ahora, solo simula la llamada.
    _apiExterna.enviarDatos(rut, idVacuna);
  }
}

/// Clase ControladorVacunacion: Controlador responsable de registrar la administración de dosis
/// y de notificar estos eventos a entidades externas utilizando el Adapter.
class ControladorVacunacion {
  final IReporteMinsal reporteMinsal;

  ControladorVacunacion(this.reporteMinsal);

  /// Corresponde al mensaje: registrarDosis() del diagrama de comunicación.
  /// Se encarga de procesar el registro y delegar el reporte a través de la interfaz IReporteMinsal.
  void registrarDosis(String rut, int idVacuna) {
    print("ControladorVacunacion: Dosis registrada localmente.");
    
    // Llamar a la interfaz del Minsal para notificar al sistema externo
    reporteMinsal.reportarPaciente(rut, idVacuna);
  }
}
