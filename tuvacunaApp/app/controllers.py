from app.models import CentroVacunacion

class ControlAgendamiento:
    # Clase responsable de gestionar la creación de nuevas citas médicas.
    # Actúa como controlador en el diagrama de comunicación para agendar citas.
    @staticmethod
    def agendarCita(rutPaciente, idCentro, fecha, hora):
        # Coordina la creación de una nueva cita buscando el Centro de Vacunación
        # y delegandole la responsabilidad de crear la cita.
        centro = CentroVacunacion.query.get(idCentro)
        if centro:
            return centro.agregarCita(rutPaciente, idCentro, fecha, hora)
        return False, "Centro de vacunación no encontrado."

class ControladorConsulta:
    # Clase responsable de gestionar las consultas relacionadas con el paciente,
    # específicamente para obtener su historial de vacunación.
    @staticmethod
    def obtenerHistorialVacunacion(rutPaciente):
        # Retorna una lista de strings con las enfermedades de las que el paciente 
        # ya ha sido vacunado.
        from app.models import Paciente
        paciente = Paciente.query.filter_by(rut=rutPaciente).first()
        if not paciente:
            return []
            
        citas_asistidas = paciente.getHistorial()
        
        enfermedades_inmunizadas = []
        for cita in citas_asistidas:
            enfermedades = cita.getDetalleVacunacion()
            enfermedades_inmunizadas.extend(enfermedades)
            
        return enfermedades_inmunizadas

class ControladorVacunacion:
    # Clase responsable de registrar el evento de vacunación y comunicarlo
    # al Ministerio de Salud (Minsal).
    @staticmethod
    def registrarDosis(rut: str, idVacuna: int):
        # Utiliza AdaptadorMinsal para reportar al paciente.
        from app.minsal_adapter import AdaptadorMinsal
        adaptador = AdaptadorMinsal()
        adaptador.reportarPaciente(rut, idVacuna)
