import 'paciente.dart';

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

abstract class CreadorNotificacion {
  INotificacion crearNotificacion();
}

class CreadorNotifEmail extends CreadorNotificacion {
  @override
  INotificacion crearNotificacion() {
    return NotificacionEmail();
  }
}

class CreadorNotifSMS extends CreadorNotificacion {
  @override
  INotificacion crearNotificacion() {
    return NotificacionSMS();
  }
}
