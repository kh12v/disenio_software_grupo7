from app import app, db
from app.models import User

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        
        # Seed default users
        default_users = [
            {'rut': '00.000.000-0', 'role': 'administrator', 'password': '1234'},
            {'rut': '11.111.111-1', 'role': 'healthcare provider', 'password': '1234'},
            {'rut': '22.222.222-2', 'role': 'patient', 'password': '1234'}
        ]
        for u_data in default_users:
            if not User.query.filter_by(rut=u_data['rut']).first():
                user = User(rut=u_data['rut'], role=u_data['role'])
                user.set_password(u_data['password'])
                db.session.add(user)
        db.session.commit()
        
    app.run(debug=True)
