from abc import ABC, abstractmethod

class EstadoCita(ABC):
    @abstractmethod
    def confirmar(self, c):
        pass

    @abstractmethod
    def registrarVacunacion(self, c, v):
        pass

    @abstractmethod
    def cancelar(self, c):
        pass

class EstadoAgendada(EstadoCita):
    def confirmar(self, c):
        # Already scheduled, no operation needed for now
        pass
        
    def registrarVacunacion(self, c, v):
        c.vacunacion = v
        c.vacunacion_id = v.id
        c.estado_cita = "Realizada"

    def cancelar(self, c):
        c.estado_cita = "Cancelada"

class EstadoRealizada(EstadoCita):
    def confirmar(self, c):
        raise ValueError("La cita ya fue realizada")
        
    def registrarVacunacion(self, c, v):
        raise ValueError("La cita ya fue realizada y la vacuna registrada")
        
    def cancelar(self, c):
        raise ValueError("No se puede cancelar una cita que ya fue realizada")

class EstadoCancelada(EstadoCita):
    def confirmar(self, c):
        raise ValueError("No se puede confirmar una cita cancelada")
        
    def registrarVacunacion(self, c, v):
        raise ValueError("No se puede registrar vacunación en una cita cancelada")
        
    def cancelar(self, c):
        raise ValueError("La cita ya se encuentra cancelada")
