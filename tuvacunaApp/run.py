from app import app, db
from app.models import Persona, Organizador, EspecialistaSalud, Paciente, Campana, CentroVacunacion, Vacuna

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        
        from datetime import date
        
        # Seed default campaigns
        if not Campana.query.first():
            c1 = Campana(nombre_campana='Campaña de invierno', enfermedad_objetivo='Influenza', fecha_inicio=date(2026, 7, 1), fecha_fin=date(2026, 7, 31), poblacion_objetivo='Adultos mayores')
            c2 = Campana(nombre_campana='Campaña escolar', enfermedad_objetivo='Sarampión', fecha_inicio=date(2026, 8, 10), fecha_fin=date(2026, 8, 20), poblacion_objetivo='Estudiantes')
            db.session.add_all([c1, c2])
            db.session.commit()
            
        # Seed default centers
        if not CentroVacunacion.query.first():
            cv1 = CentroVacunacion(nombre_centro='Hospital Central', direccion='Av. Principal 123', tipo_financiamiento='Público', capacidad_atencion=100, horario_atencion='08:00 - 18:00')
            cv2 = CentroVacunacion(nombre_centro='Cesfam Norte', direccion='Calle Norte 456', tipo_financiamiento='Público', capacidad_atencion=50, horario_atencion='09:00 - 17:00')
            db.session.add_all([cv1, cv2])
            db.session.commit()
            
        # Seed default vaccine
        if not Vacuna.query.first():
            v1 = Vacuna(enfermedades=["COVID-19", "Influenza"])
            db.session.add(v1)
            db.session.commit()
            
        # Seed default users
        default_users = [
            {'rut': '00.000.000-0', 'role': 'administrator', 'password': '1234', 'nombre': 'Admin User'},
            {'rut': '11.111.111-1', 'role': 'healthcare provider', 'password': '1234', 'nombre': 'Doctor User'},
            {'rut': '22.222.222-2', 'role': 'patient', 'password': '1234', 'nombre': 'Patient User'}
        ]
        
        for u_data in default_users:
            persona = Persona.query.filter_by(rut=u_data['rut']).first()
            if not persona:
                persona = Persona(rut=u_data['rut'], nombre=u_data['nombre'])
                persona.set_clave_unica(u_data['password'])
                db.session.add(persona)
                
                paciente = Paciente(rut=u_data['rut'], nombres=u_data['nombre'], correo=f"{u_data['role'].replace(' ', '_')}@example.com")
                db.session.add(paciente)
                
                if u_data['role'] == 'administrator':
                    organizador = Organizador(rut=u_data['rut'], nombres=u_data['nombre'], cargo='Administrador Principal')
                    db.session.add(organizador)
                elif u_data['role'] == 'healthcare provider':
                    centro_prueba = CentroVacunacion.query.first()
                    especialista = EspecialistaSalud(rut=u_data['rut'], nombres=u_data['nombre'], especialidad='Medicina General', centro_id=centro_prueba.id if centro_prueba else None)
                    db.session.add(especialista)
                    
        db.session.commit()
        
    app.run(debug=True)
