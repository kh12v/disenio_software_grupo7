from app import app, db
from app.models import Persona
with app.app_context():
    client = app.test_client()
    p = Persona.query.filter_by(rut='11.111.111-1').first()
    with client.session_transaction() as sess:
        sess['_user_id'] = str(p.id)
        sess['role'] = 'paciente'
    resp = client.get('/patient_dashboard')
    print('111:', 'COVID-19' in resp.get_data(as_text=True))
