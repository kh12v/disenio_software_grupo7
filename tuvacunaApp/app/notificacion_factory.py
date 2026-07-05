from abc import ABC, abstractmethod
from datetime import datetime
from app import db
from app.models import Notificacion, Paciente

class INotificacion(ABC):
    # Interfaz común para todas las notificaciones creadas por el Factory.
    @abstractmethod
    def enviar(self, mensaje: str, p: Paciente):
        # Envía la notificación al paciente y la guarda en la base de datos.
        pass

class NotificacionEmail(INotificacion):
    # Implementación concreta para notificaciones por correo electrónico.
    def enviar(self, mensaje: str, p: Paciente):
        from app.email_service import EmailService
        
        try:
            email_service = EmailService()
            subject = "Actualización de tu Cita - TuVacunaApp"
            content = f"<h2>Hola {p.nombres},</h2><p>{mensaje}</p>"
            email_service.send_email(
                to_email=p.correo,
                subject=subject,
                content=content
            )
            print(f"Correo enviado exitosamente a {p.correo}")
        except Exception as e:
            print(f"No se pudo enviar el correo a {p.correo}. Detalles: {str(e)}")
        
        # Guarda el registro en la base de datos
        notificacion = Notificacion(
            mensaje=mensaje,
            canal_envio="Email",
            fecha_envio=datetime.now()
        )
        db.session.add(notificacion)

class NotificacionSMS(INotificacion):
    # Implementación concreta para notificaciones por SMS.
    def enviar(self, mensaje: str, p: Paciente):
        # Simulación del envío de SMS
        print(f"[API SMS SIMULADA] Enviando SMS al teléfono {p.telefono}: {mensaje}")
        
        # Guarda el registro en la base de datos
        notificacion = Notificacion(
            mensaje=mensaje,
            canal_envio="SMS",
            fecha_envio=datetime.now()
        )
        db.session.add(notificacion)

class CreadorNotificacion(ABC):
    # Clase abstracta que declara el Factory Method que retorna un objeto INotificacion.
    @abstractmethod
    def crearNotificacion(self) -> INotificacion:
        pass

class CreadorNotifEmail(CreadorNotificacion):
    # Sobrescribe el Factory Method para retornar una instancia de NotificacionEmail.
    def crearNotificacion(self) -> INotificacion:
        return NotificacionEmail()

class CreadorNotifSMS(CreadorNotificacion):
    # Sobrescribe el Factory Method para retornar una instancia de NotificacionSMS.
    def crearNotificacion(self) -> INotificacion:
        return NotificacionSMS()
