import 'paciente.dart';

/// PATRÓN DE DISEÑO: Factory Method
/// Interfaz INotificacion: Interfaz común para todos los productos de notificación.
/// Contiene el método enviar(mensaje, p) proveniente del diagrama de clases.
abstract class INotificacion {
  String get mensaje;
  String get canalEnvio;
  DateTime get fechaEnvio;

  void enviar(String mensaje, Paciente p);

  Map<String, dynamic> toJson();
}

class NotificacionEmail implements INotificacion {
  String _mensaje = '';
  final String _canalEnvio = 'email';
  final DateTime _fechaEnvio = DateTime.now();

  String? _rutPaciente;
  String? _nombrePaciente;

  @override
  String get mensaje => _mensaje;

  @override
  String get canalEnvio => _canalEnvio;

  @override
  DateTime get fechaEnvio => _fechaEnvio;

  @override
  void enviar(String mensaje, Paciente p) {
    _mensaje = mensaje;
    _rutPaciente = p.rut;
    _nombrePaciente = '${p.nombres} ${p.apellidos}';

    print("Enviando Email a ${p.nombres} ${p.apellidos}: $mensaje");
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': 'email',
      'mensaje': mensaje,
      'canal_envio': canalEnvio,
      'fecha_envio': fechaEnvio.toIso8601String(),
      if (_rutPaciente != null) 'rut_paciente': _rutPaciente,
      if (_nombrePaciente != null) 'nombre_paciente': _nombrePaciente,
    };
  }
}

class NotificacionSMS implements INotificacion {
  String _mensaje = '';
  final String _canalEnvio = 'SMS';
  final DateTime _fechaEnvio = DateTime.now();

  String? _rutPaciente;
  String? _nombrePaciente;

  @override
  String get mensaje => _mensaje;

  @override
  String get canalEnvio => _canalEnvio;

  @override
  DateTime get fechaEnvio => _fechaEnvio;

  @override
  void enviar(String mensaje, Paciente p) {
    _mensaje = mensaje;
    _rutPaciente = p.rut;
    _nombrePaciente = '${p.nombres} ${p.apellidos}';

    print("Enviando SMS a ${p.nombres} ${p.apellidos}: $mensaje");
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': 'sms',
      'mensaje': mensaje,
      'canal_envio': canalEnvio,
      'fecha_envio': fechaEnvio.toIso8601String(),
      if (_rutPaciente != null) 'rut_paciente': _rutPaciente,
      if (_nombrePaciente != null) 'nombre_paciente': _nombrePaciente,
    };
  }
}

/// PATRÓN DE DISEÑO: Factory Method
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