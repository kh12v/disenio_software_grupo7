import 'paciente.dart';

/// PATRÓN DE DISEÑO: Factory Method
/// Interfaz INotificacion: Interfaz común para todos los productos de notificación.
/// Contiene el método enviar(mensaje, p) proveniente del diagrama de clases.
abstract class INotificacion {
  String get mensaje;
  String get canalEnvio;
  DateTime get fechaEnvio;
  
  void enviar(String mensaje, Paciente p);
}

class NotificacionEmail implements INotificacion {
  String _mensaje = '';
  final String _canalEnvio = 'email';
  final DateTime _fechaEnvio = DateTime.now();

  @override
  String get mensaje => _mensaje;
  
  @override
  String get canalEnvio => _canalEnvio;
  
  @override
  DateTime get fechaEnvio => _fechaEnvio;

  @override
  void enviar(String mensaje, Paciente p) {
    _mensaje = mensaje;
    print("Enviando Email a \${p.nombres} \${p.apellidos}: \$mensaje");
  }
}

class NotificacionSMS implements INotificacion {
  String _mensaje = '';
  final String _canalEnvio = 'SMS';
  final DateTime _fechaEnvio = DateTime.now();

  @override
  String get mensaje => _mensaje;
  
  @override
  String get canalEnvio => _canalEnvio;
  
  @override
  DateTime get fechaEnvio => _fechaEnvio;

  @override
  void enviar(String mensaje, Paciente p) {
    _mensaje = mensaje;
    print("Enviando SMS a \${p.nombres} \${p.apellidos}: \$mensaje");
  }
}

/// PATRÓN DE DISEÑO: Factory Method
/// CreadorNotificacion: Clase abstracta que declara el Factory Method.
/// Responsabilidad: Delegar la instanciación de notificaciones a sus subclases concretas.
abstract class CreadorNotificacion {
  /// Corresponde al mensaje: crearNotificacion() del patrón Factory Method.
  INotificacion crearNotificacion();
}

/// PATRÓN DE DISEÑO: Factory Method
/// CreadorNotifEmail: Creador que instancia productos NotificacionEmail.
class CreadorNotifEmail extends CreadorNotificacion {
  @override
  INotificacion crearNotificacion() {
    return NotificacionEmail();
  }
}

/// PATRÓN DE DISEÑO: Factory Method
/// CreadorNotifSMS: Creador que instancia productos NotificacionSMS.
class CreadorNotifSMS extends CreadorNotificacion {
  @override
  INotificacion crearNotificacion() {
    return NotificacionSMS();
  }
}
