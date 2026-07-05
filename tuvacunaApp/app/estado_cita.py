from abc import ABC, abstractmethod

class EstadoCita(ABC):
    # Define la interfaz común que deben implementar todos los estados 
    # específicos por los que transiciona una Cita.
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
    # PATRÓN APLICADO: State (Estado Concreto)
    # Estado inicial de una cita una vez creada. Permite ser realizada o cancelada.
    def confirmar(self, c):
        # No acción requerida
        pass
        
    def registrarVacunacion(self, c, v):
        c.vacunacion = v
        c.vacunacion_id = v.id
        c.estado_cita = "Realizada"

    def cancelar(self, c):
        c.estado_cita = "Cancelada"

class EstadoRealizada(EstadoCita):
    # Estado final de la cita cuando la vacuna fue suministrada.
    # Impide transiciones de estado posteriores.
    def confirmar(self, c):
        raise ValueError("La cita ya fue realizada")
        
    def registrarVacunacion(self, c, v):
        raise ValueError("La cita ya fue realizada y la vacuna registrada")
        
    def cancelar(self, c):
        raise ValueError("No se puede cancelar una cita que ya fue realizada")

class EstadoCancelada(EstadoCita):
    # Estado final de la cita si no se lleva a cabo.
    # Impide volver a confirmar o vacunar en esta cita.
    def confirmar(self, c):
        raise ValueError("No se puede confirmar una cita cancelada")
        
    def registrarVacunacion(self, c, v):
        raise ValueError("No se puede registrar vacunación en una cita cancelada")
        
    def cancelar(self, c):
        raise ValueError("La cita ya se encuentra cancelada")
