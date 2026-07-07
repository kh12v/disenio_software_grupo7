from app import db, login_manager
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

class Persona(UserMixin, db.Model):
    # Simula la base de datos gubernamental del Registro Civil (RUT, Nombre, Clave Única)
    id = db.Column(db.Integer, primary_key=True)
    rut = db.Column(db.String(12), index=True, unique=True)
    nombre = db.Column(db.String(200))
    clave_unica_hash = db.Column(db.String(256))

    def set_clave_unica(self, clave):
        self.clave_unica_hash = generate_password_hash(clave)

    def check_clave_unica(self, clave):
        return check_password_hash(self.clave_unica_hash, clave)

class Organizador(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    rut = db.Column(db.String(12), unique=True, index=True)
    nombres = db.Column(db.String(100))
    apellidos = db.Column(db.String(100))
    cargo = db.Column(db.String(100))

class Campana(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nombre_campana = db.Column(db.String(200))
    enfermedad_objetivo = db.Column(db.String(200))
    fecha_inicio = db.Column(db.Date)
    fecha_fin = db.Column(db.Date)
    poblacion_objetivo = db.Column(db.String(200))

class CentroVacunacion(db.Model):
    # Representa un Centro de Vacunación en el sistema.
    # Es responsable de almacenar la información del centro y manejar
    # la agregación de nuevas citas para los pacientes en sus instalaciones.
    id = db.Column(db.Integer, primary_key=True)
    nombre_centro = db.Column(db.String(200))
    direccion = db.Column(db.String(300))
    tipo_financiamiento = db.Column(db.String(50))
    capacidad_atencion = db.Column(db.Integer)
    horario_atencion = db.Column(db.String(100))

    def buscarPaciente(self, rutPaciente):
        # Retorna la instancia del paciente asociado al RUT indicado.
        from app.models import Paciente
        return Paciente.query.filter_by(rut=rutPaciente).first()
        
    def create(self, fecha, hora, paciente):
        # Crea la instancia de la Cita en la base de datos 
        # asociándola a este centro y al paciente dado.
        from app.models import Cita
        from datetime import datetime
        
        # Encontramos cualquier especialista en este centro
        especialista = EspecialistaSalud.query.filter_by(centro_id=self.id).first()
        if not especialista:
            return False, "No hay especialistas disponibles en este centro."
            
        nueva_cita = Cita(
            fecha=fecha,
            hora=hora,
            estado_cita='Agendada',
            centro_id=self.id,
            paciente_id=paciente.id,
            especialista_id=especialista.id
        )
        db.session.add(nueva_cita)
        db.session.commit()
        return True, "Cita agendada exitosamente."

    def agregarCita(self, rutPaciente, idCentro, fecha, hora):
        # Coordina la lógica interna del centro para ubicar al paciente
        # y generar su cita.
        p = self.buscarPaciente(rutPaciente)
        if not p:
            return False, 'Paciente no encontrado.'
        
        # Mensaje del diagrama de comunicación: create(fecha, hora, p)
        return self.create(fecha, hora, p)

class Vacuna(db.Model):
    # Representa una vacuna dentro del sistema.
    # Mantiene la información sobre las enfermedades que previene.
    id = db.Column(db.Integer, primary_key=True)
    id_minsal = db.Column(db.Integer, default=0)
    enfermedades = db.Column(db.JSON)

    def getEnfermedades(self):
        # Retorna la lista de enfermedades que cubre esta vacuna específica.
        return self.enfermedades if self.enfermedades else []

class InventarioVacuna(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    centro_id = db.Column(db.Integer, db.ForeignKey('centro_vacunacion.id'))
    vacuna_id = db.Column(db.Integer, db.ForeignKey('vacuna.id'))
    cantidad = db.Column(db.Integer, default=0)

    centro = db.relationship('CentroVacunacion', backref=db.backref('inventario', lazy=True))
    vacuna = db.relationship('Vacuna', backref=db.backref('inventario_centros', lazy=True))

class Notificacion(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    mensaje = db.Column(db.Text)
    canal_envio = db.Column(db.String(50))
    fecha_envio = db.Column(db.DateTime)

class Paciente(db.Model):
    # Representa a un paciente del sistema.
    # Es responsable de proporcionar acceso a sus registros médicos y citas.
    id = db.Column(db.Integer, primary_key=True)
    rut = db.Column(db.String(12), unique=True, index=True)
    nombres = db.Column(db.String(100))
    apellidos = db.Column(db.String(100))
    fecha_nacimiento = db.Column(db.Date)
    telefono = db.Column(db.String(20))
    correo = db.Column(db.String(120))

    def getHistorial(self):
        # Retorna la lista de las citas a las que el paciente ya ha asistido y
        # cuya vacunación ha sido concretada.
        return [c for c in self.citas if c.estado_cita in ['Completa', 'Realizada']]

class Cita(db.Model):
    # Representa una cita médica programada.
    # Gestiona su estado mediante instancias de EstadoCita.
    id = db.Column(db.Integer, primary_key=True)
    fecha = db.Column(db.Date)
    hora = db.Column(db.Time)
    estado_cita = db.Column(db.String(50))
    cancelacion_motivo = db.Column(db.Text)
    centro_id = db.Column(db.Integer, db.ForeignKey('centro_vacunacion.id'))
    paciente_id = db.Column(db.Integer, db.ForeignKey('paciente.id'))
    especialista_id = db.Column(db.Integer, db.ForeignKey('especialista_salud.id'))
    vacunacion_id = db.Column(db.Integer, db.ForeignKey('vacunacion.id'))

    centro = db.relationship('CentroVacunacion', backref=db.backref('citas', lazy=True))
    paciente = db.relationship('Paciente', backref=db.backref('citas', lazy=True))
    especialista = db.relationship('EspecialistaSalud', foreign_keys=[especialista_id], backref=db.backref('citas_atendidas', lazy=True))
    vacunacion = db.relationship('Vacunacion', backref=db.backref('cita_asociada', uselist=False, lazy=True))

    def getDetalleVacunacion(self):
        # Retorna las enfermedades asociadas a la vacunación realizada en esta cita.
        return self.getInfoVacuna()

    def getInfoVacuna(self):
        # Extrae y devuelve la lista de enfermedades desde el objeto Vacuna vinculado.
        if self.vacunacion and self.vacunacion.vacuna:
            return self.vacunacion.vacuna.getEnfermedades()
        return []

    @property
    def estadoActual(self):
        # Retorna la instancia del estado concreto correspondiente basándose en 
        # la columna string 'estado_cita' de la base de datos.
        from app.estado_cita import EstadoAgendada, EstadoRealizada, EstadoCancelada
        if self.estado_cita == "Agendada":
            return EstadoAgendada()
        elif self.estado_cita in ["Realizada", "Completa"]:
            return EstadoRealizada()
        elif self.estado_cita == "Cancelada":
            return EstadoCancelada()
        return EstadoAgendada() # default

    def confirmar(self):
        # Delega el comportamiento al estado actual.
        self.estadoActual.confirmar(self)

    def registrarVacunacion(self, v):
        # Delega el registro de la vacunación al estado actual.
        self.estadoActual.registrarVacunacion(self, v)

    def cancelar(self):
        # Delega la cancelación de la cita al estado actual.
        self.estadoActual.cancelar(self)

class EspecialistaSalud(db.Model):
    # Representa un especialista en salud, quien trabaja en determinado centro.
    id = db.Column(db.Integer, primary_key=True)
    rut = db.Column(db.String(12), unique=True, index=True)
    licencia = db.Column(db.String(100))
    nombres = db.Column(db.String(100))
    apellidos = db.Column(db.String(100))
    especialidad = db.Column(db.String(100))
    centro_id = db.Column(db.Integer, db.ForeignKey('centro_vacunacion.id'))
    
    centro = db.relationship('CentroVacunacion', backref=db.backref('especialistas', lazy=True))

class Vacunacion(db.Model):
    # Representa la vacunación administrada a un paciente en una cita determinada.
    id = db.Column(db.Integer, primary_key=True)
    fecha_aplicacion = db.Column(db.Date)
    numero_dosis = db.Column(db.Integer)
    observaciones_reacciones = db.Column(db.Text)
    vacuna_id = db.Column(db.Integer, db.ForeignKey('vacuna.id'))
    especialista_id = db.Column(db.Integer, db.ForeignKey('especialista_salud.id'))

    vacuna = db.relationship('Vacuna', backref=db.backref('vacunaciones', lazy=True))
    especialista = db.relationship('EspecialistaSalud', foreign_keys=[especialista_id], backref=db.backref('vacunaciones_realizadas', lazy=True))

@login_manager.user_loader
def load_user(id):
    return Persona.query.get(int(id))
