from app import app, db
from app.models import Persona, Organizador, EspecialistaSalud, Paciente

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        
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
                
                # Everyone is registered as a patient by default
                paciente = Paciente(rut=u_data['rut'], nombres=u_data['nombre'], correo=f"{u_data['role']}@example.com")
                db.session.add(paciente)
                
                if u_data['role'] == 'administrator':
                    organizador = Organizador(rut=u_data['rut'], nombres=u_data['nombre'], cargo='Administrador Principal')
                    db.session.add(organizador)
                elif u_data['role'] == 'healthcare provider':
                    especialista = EspecialistaSalud(rut=u_data['rut'], nombres=u_data['nombre'], especialidad='Medicina General')
                    db.session.add(especialista)
                    
        db.session.commit()
        
    app.run(debug=True)
