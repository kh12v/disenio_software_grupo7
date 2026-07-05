from app import db, login_manager
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

class Persona(UserMixin, db.Model):
    """
    Simula la base de datos gubernamental del Registro Civil (RUT, Nombre, Clave Única)
    """
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
    id = db.Column(db.Integer, primary_key=True)
    nombre_centro = db.Column(db.String(200))
    direccion = db.Column(db.String(300))
    tipo_financiamiento = db.Column(db.String(50))
    capacidad_atencion = db.Column(db.Integer)
    horario_atencion = db.Column(db.String(100))

    def buscarPaciente(self, rutPaciente):
        from app.models import Paciente
        return Paciente.query.filter_by(rut=rutPaciente).first()
        
    def create(self, fecha, hora, p):
        from app.models import Cita, EspecialistaSalud
        from app import db
        
        # Validación: revisar si ya existe una cita en esa fecha y hora
        cita_existente = Cita.query.filter_by(centro_id=self.id, fecha=fecha, hora=hora).first()
        if cita_existente:
            return False, 'Lo sentimos, este horario ya está reservado para el centro seleccionado.'
            
        especialista = EspecialistaSalud.query.filter_by(centro_id=self.id).first()
        
        nueva_cita = Cita(
            fecha=fecha,
            hora=hora,
            estado_cita='Pendiente',
            centro_id=self.id,
            paciente_id=p.id,
            especialista_id=especialista.id if especialista else None
        )
        db.session.add(nueva_cita)
        db.session.commit()
        return True, '¡Cita solicitada exitosamente!'
        
    def agregarCita(self, rutPaciente, idCentro, fecha, hora):
        p = self.buscarPaciente(rutPaciente)
        if not p:
            return False, 'Paciente no encontrado.'
        return self.create(fecha, hora, p)
class Vacuna(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    enfermedades = db.Column(db.JSON)

    def getEnfermedades(self):
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
    id = db.Column(db.Integer, primary_key=True)
    rut = db.Column(db.String(12), unique=True, index=True)
    nombres = db.Column(db.String(100))
    apellidos = db.Column(db.String(100))
    fecha_nacimiento = db.Column(db.Date)
    telefono = db.Column(db.String(20))
    correo = db.Column(db.String(120))

    def getHistorial(self):
        # Devuelve las citas en las que el paciente ya fue vacunado
        return [c for c in self.citas if c.estado_cita == 'Completa']

class Cita(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    fecha = db.Column(db.Date)
    hora = db.Column(db.Time)
    estado_cita = db.Column(db.String(50))
    centro_id = db.Column(db.Integer, db.ForeignKey('centro_vacunacion.id'))
    paciente_id = db.Column(db.Integer, db.ForeignKey('paciente.id'))
    especialista_id = db.Column(db.Integer, db.ForeignKey('especialista_salud.id'))
    vacunacion_id = db.Column(db.Integer, db.ForeignKey('vacunacion.id'))

    centro = db.relationship('CentroVacunacion', backref=db.backref('citas', lazy=True))
    paciente = db.relationship('Paciente', backref=db.backref('citas', lazy=True))
    especialista = db.relationship('EspecialistaSalud', foreign_keys=[especialista_id], backref=db.backref('citas_atendidas', lazy=True))
    vacunacion = db.relationship('Vacunacion', backref=db.backref('cita_asociada', uselist=False, lazy=True))

    def getDetalleVacunacion(self):
        return self.getInfoVacuna()

    def getInfoVacuna(self):
        if self.vacunacion and self.vacunacion.vacuna:
            return self.vacunacion.vacuna.getEnfermedades()
        return []

class EspecialistaSalud(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    rut = db.Column(db.String(12), unique=True, index=True)
    licencia = db.Column(db.String(100))
    nombres = db.Column(db.String(100))
    apellidos = db.Column(db.String(100))
    especialidad = db.Column(db.String(100))
    centro_id = db.Column(db.Integer, db.ForeignKey('centro_vacunacion.id'))
    
    centro = db.relationship('CentroVacunacion', backref=db.backref('especialistas', lazy=True))

class Vacunacion(db.Model):
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
