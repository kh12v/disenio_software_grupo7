from flask import render_template, redirect, url_for, flash, request, session
from app import app, db
from app.models import Persona, Organizador, EspecialistaSalud, Paciente, Campana, CentroVacunacion, Cita
from flask_login import current_user, login_user, logout_user, login_required
from urllib.parse import urlsplit
import re
from datetime import datetime

@app.route('/')
@app.route('/index')
def index():
    if not current_user.is_authenticated:
        return redirect(url_for('login'))
        
    role = session.get('role')
    if role == 'organizador':
        return redirect(url_for('organizador_dashboard'))
    elif role == 'especialista':
        return redirect(url_for('especialista_dashboard'))
    else:
        return redirect(url_for('patient_dashboard'))

@app.route('/campaigns')
def campaigns():
    campaigns_data = Campana.query.all()
    # Format dates as strings for the template
    formatted_campaigns = []
    for c in campaigns_data:
        formatted_campaigns.append({
            'name': c.nombre_campana,
            'description': f'Enfermedad objetivo: {c.enfermedad_objetivo}. Población: {c.poblacion_objetivo}',
            'start_date': c.fecha_inicio.strftime('%Y-%m-%d'),
            'end_date': c.fecha_fin.strftime('%Y-%m-%d'),
            'status': 'Activa' if c.fecha_inicio <= datetime.now().date() <= c.fecha_fin else 'Programada' if c.fecha_inicio > datetime.now().date() else 'Finalizada',
            'registered_people_count': 0 # Mock count for now
        })
    return render_template(
        'campaigns.html',
        title='Campañas de vacunación',
        campaigns=formatted_campaigns
    )

@app.route('/request_appointment', methods=['GET', 'POST'])
@login_required
def request_appointment():
    if session.get('role') != 'patient':
        flash('Debes ingresar como paciente para solicitar una cita.')
        return redirect(url_for('index'))
        
    campanas = Campana.query.all()
    centros = CentroVacunacion.query.all()
    
    # Simulated dates/times as requested
    horarios_simulados = [
        {'fecha': '2026-07-02', 'hora': '16:00'},
        {'fecha': '2026-07-03', 'hora': '10:00'},
        {'fecha': '2026-07-04', 'hora': '14:30'}
    ]
    
    # Get booked appointments to pass to frontend
    citas_agendadas = Cita.query.all()
    citas_ocupadas_por_centro = {}
    for c in citas_agendadas:
        centro_id_str = str(c.centro_id)
        if centro_id_str not in citas_ocupadas_por_centro:
            citas_ocupadas_por_centro[centro_id_str] = []
        citas_ocupadas_por_centro[centro_id_str].append(f"{c.fecha.strftime('%Y-%m-%d')} {c.hora.strftime('%H:%M')}")
    
    if request.method == 'POST':
        centro_id = request.form.get('centro_id')
        horario_seleccionado = request.form.get('horario')
        
        if not centro_id or not horario_seleccionado:
            flash('Por favor completa todos los campos.')
            return redirect(url_for('request_appointment'))
            
        fecha_str, hora_str = horario_seleccionado.split(' ')
        fecha_obj = datetime.strptime(fecha_str, '%Y-%m-%d').date()
        hora_obj = datetime.strptime(hora_str, '%H:%M').time()
        
        # Check if already booked
        cita_existente = Cita.query.filter_by(centro_id=centro_id, fecha=fecha_obj, hora=hora_obj).first()
        if cita_existente:
            flash('Lo sentimos, este horario ya está reservado para el centro seleccionado.')
            return redirect(url_for('request_appointment'))
        
        paciente = Paciente.query.filter_by(rut=current_user.rut).first()
        especialista = EspecialistaSalud.query.filter_by(centro_id=centro_id).first()
        
        nueva_cita = Cita(
            fecha=fecha_obj,
            hora=hora_obj,
            estado_cita='Pendiente',
            centro_id=centro_id,
            paciente_id=paciente.id,
            especialista_id=especialista.id if especialista else None
        )
        db.session.add(nueva_cita)
        db.session.commit()
        
        flash('¡Cita solicitada exitosamente!')
        return redirect(url_for('patient_dashboard'))
        
    return render_template('request_appointment.html', title='Solicitar Cita', campanas=campanas, centros=centros, horarios=horarios_simulados, citas_ocupadas_por_centro=citas_ocupadas_por_centro)
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
    paciente = Paciente.query.filter_by(rut=current_user.rut).first()
    citas = []
    if paciente:
        citas = Cita.query.filter_by(paciente_id=paciente.id).all()
        
    return render_template('patient_dashboard.html', title='Panel de Paciente', citas=citas)

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
