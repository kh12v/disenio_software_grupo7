from abc import ABC, abstractmethod

class IReporteMinsal(ABC):
    # Reporta pacientes vacunados al Ministerio de Salud.
    @abstractmethod
    def reportarPaciente(self, rut: str, idVacuna: int):
        pass

class APIExternaMinsal:
    # Simulación de un SDK externo de la API del Minsal (Ministerio de Salud).
    def enviar_datos_vacunacion(self, rut_paciente: str, vacuna_id: int):
        print(f"[APIExternaMinsal] Datos recibidos y procesados correctamente: Paciente RUT {rut_paciente} vacunado con dosis ID {vacuna_id}")
        return True

class AdaptadorMinsal(IReporteMinsal):
    # Implementa la interfaz IReporteMinsal y envuelve la APIExternaMinsal
    # traduciendo las llamadas locales hacia el sistema externo.
    def __init__(self):
        self.api_externa = APIExternaMinsal()
        
    def reportarPaciente(self, rut: str, idVacuna: int):
        # El adaptador traduce la llamada a la interfaz requerida por el cliente
        # a los métodos específicos provistos por la librería externa.
        return self.api_externa.enviar_datos_vacunacion(rut, idVacuna)
