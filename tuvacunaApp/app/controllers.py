from app.models import CentroVacunacion

class ControlAgendamiento:
    @staticmethod
    def agendarCita(rutPaciente, idCentro, fecha, hora):
        """
        Maneja la creación de nuevas citas coordinando con el CentroVacunacion.
        Sigue el diagrama de comunicaciones especificado.
        """
        centro = CentroVacunacion.query.get(idCentro)
        if centro:
            # Llama al método agregarCita del Centro de Vacunación
            return centro.agregarCita(rutPaciente, idCentro, fecha, hora)
        return False, "Centro de vacunación no encontrado."

class ControladorConsulta:
    @staticmethod
    def obtenerHistorialVacunacion(rutPaciente):
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
    @staticmethod
    def registrarDosis(rut: str, idVacuna: int):
        from app.minsal_adapter import AdaptadorMinsal
        adaptador = AdaptadorMinsal()
        adaptador.reportarPaciente(rut, idVacuna)
