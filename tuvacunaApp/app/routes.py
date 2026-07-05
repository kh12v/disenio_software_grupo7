from flask import render_template, redirect, url_for, flash, request, session
from app import app, db
from app.models import Persona, Organizador, EspecialistaSalud, Paciente
from flask_login import current_user, login_user, logout_user, login_required
from urllib.parse import urlsplit
import re

@app.route('/')
@app.route('/index')
@login_required
def index():
    return render_template('index.html', title='Inicio')

@app.route('/campaigns')
def campaigns():
    campaigns = [
        {
            'name': 'Campaña de invierno',
            'description': 'Vacunación contra influenza para adultos mayores y personas de riesgo.',
            'start_date': '2026-07-01',
            'end_date': '2026-07-31',
            'status': 'Activa',
            'registered_people_count': 842
        },
        {
            'name': 'Campaña escolar',
            'description': 'Aplicación de vacunas para estudiantes del sistema escolar municipal.',
            'start_date': '2026-08-10',
            'end_date': '2026-08-20',
            'status': 'Próximamente',
            'registered_people_count': 324
        },
        {
            'name': 'Campaña comunitaria',
            'description': 'Atención en centros comunales para la vacunación de la comunidad.',
            'start_date': '2026-09-01',
            'end_date': '2026-09-15',
            'status': 'Programada',
            'registered_people_count': 118
        }
    ]
    return render_template(
        'campaigns.html',
        title='Campañas de vacunación',
        campaigns=campaigns
    )

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    if request.method == 'POST':
        rut = request.form['rut']
        if not re.match(r'^\d{1,2}\.\d{3}\.\d{3}-[\dkK]$', rut):
            flash('Formato de RUT inválido')
            return redirect(url_for('login'))
        
        # Verify against Persona
        persona = Persona.query.filter_by(rut=rut).first()
        if persona is None or not persona.check_clave_unica(request.form['password']):
            flash('RUT o clave única inválidos')
            return redirect(url_for('login'))
            
        # Check if they have special roles
        es_organizador = Organizador.query.filter_by(rut=rut).first() is not None
        es_especialista = EspecialistaSalud.query.filter_by(rut=rut).first() is not None
        
        if es_organizador or es_especialista:
            session['temp_rut'] = rut
            session['remember_me'] = 'remember_me' in request.form
            return redirect(url_for('choose_role'))
        else:
            login_user(persona, remember='remember_me' in request.form)
            session['role'] = 'patient'
            return redirect(url_for('patient_dashboard'))
            
    return render_template('login.html', title='Iniciar sesión')

@app.route('/choose_role', methods=['GET', 'POST'])
def choose_role():
    if 'temp_rut' not in session:
        return redirect(url_for('login'))
        
    rut = session['temp_rut']
    es_organizador = Organizador.query.filter_by(rut=rut).first() is not None
    es_especialista = EspecialistaSalud.query.filter_by(rut=rut).first() is not None
    
    if request.method == 'POST':
        role = request.form.get('role')
        persona = Persona.query.filter_by(rut=rut).first()
        
        if role == 'organizador' and es_organizador:
            login_user(persona, remember=session.get('remember_me', False))
            session['role'] = 'organizador'
            session.pop('temp_rut', None)
            session.pop('remember_me', None)
            return redirect(url_for('organizador_dashboard'))
            
        elif role == 'especialista' and es_especialista:
            login_user(persona, remember=session.get('remember_me', False))
            session['role'] = 'especialista'
            session.pop('temp_rut', None)
            session.pop('remember_me', None)
            return redirect(url_for('especialista_dashboard'))
            
        elif role == 'patient':
            login_user(persona, remember=session.get('remember_me', False))
            session['role'] = 'patient'
            session.pop('temp_rut', None)
            session.pop('remember_me', None)
            return redirect(url_for('patient_dashboard'))
            
        flash('Rol inválido seleccionado.')
        
    return render_template('choose_role.html', es_organizador=es_organizador, es_especialista=es_especialista, title='Seleccionar Rol')

@app.route('/patient_dashboard')
@login_required
def patient_dashboard():
    return render_template('patient_dashboard.html', title='Panel de Paciente')

@app.route('/especialista_dashboard')
@login_required
def especialista_dashboard():
    if session.get('role') != 'especialista':
        return redirect(url_for('index'))
    return render_template('especialista_dashboard.html', title='Panel de Especialista')

@app.route('/organizador_dashboard')
@login_required
def organizador_dashboard():
    if session.get('role') != 'organizador':
        return redirect(url_for('index'))
    return render_template('organizador_dashboard.html', title='Panel de Organizador')

@app.route('/logout')
def logout():
    logout_user()
    session.pop('role', None)
    return redirect(url_for('index'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    if request.method == 'POST':
        rut = request.form['rut']
        if not re.match(r'^\d{1,2}\.\d{3}\.\d{3}-[\dkK]$', rut):
            flash('Formato de RUT inválido')
            return redirect(url_for('register'))
            
        persona = Persona.query.filter_by(rut=rut).first()
        if persona is not None:
            flash('Por favor usa un RUT diferente.')
            return redirect(url_for('register'))
            
        persona = Persona(rut=rut, nombre="Usuario Nuevo")
        persona.set_clave_unica(request.form['password'])
        db.session.add(persona)
        
        paciente = Paciente(rut=rut, correo=request.form['email'])
        db.session.add(paciente)
        
        db.session.commit()
        flash('¡Felicidades, te has registrado exitosamente!')
        return redirect(url_for('login'))
    return render_template('register.html', title='Registro')
