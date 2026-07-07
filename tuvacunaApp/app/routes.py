from flask import render_template, redirect, url_for, flash, request, session
from app import app, db
from app.models import Persona, Organizador, EspecialistaSalud, Paciente, Campana, CentroVacunacion, Cita, Vacuna, Vacunacion, Notificacion
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
        
        from app.controllers import ControlAgendamiento
        
        success, message = ControlAgendamiento.agendarCita(
            rutPaciente=current_user.rut,
            idCentro=centro_id,
            fecha=fecha_obj,
            hora=hora_obj
        )
        
        if success:
            flash(message)
            return redirect(url_for('patient_dashboard'))
        else:
            flash(message)
            return redirect(url_for('request_appointment'))
        
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
    historial = []
    if paciente:
        citas = Cita.query.filter_by(paciente_id=paciente.id).all()
        from app.controllers import ControladorConsulta
        historial = ControladorConsulta.obtenerHistorialVacunacion(current_user.rut)
        
    return render_template('patient_dashboard.html', title='Panel de Paciente', citas=citas, historial=historial)

@app.route('/especialista_dashboard')
@login_required
def especialista_dashboard():
    if session.get('role') != 'especialista':
        return redirect(url_for('index'))
        
    especialista = EspecialistaSalud.query.filter_by(rut=current_user.rut).first()
    citas_pendientes = []
    if especialista:
        citas_pendientes = Cita.query.filter_by(especialista_id=especialista.id, estado_cita='Agendada').all()
        
    return render_template('especialista_dashboard.html', title='Panel de Especialista', citas=citas_pendientes)

@app.route('/process_cita/<int:cita_id>', methods=['GET', 'POST'])
@login_required
def process_cita(cita_id):
    if session.get('role') != 'especialista':
        return redirect(url_for('index'))
        
    cita = Cita.query.get_or_404(cita_id)
    especialista = EspecialistaSalud.query.filter_by(rut=current_user.rut).first()
    
    # Check if the appointment belongs to this specialist and is pending
    if cita.especialista_id != especialista.id or cita.estado_cita != 'Agendada':
        flash('No tienes permiso para atender esta cita o ya no está pendiente.')
        return redirect(url_for('especialista_dashboard'))
        
    vacunas = Vacuna.query.all()
    
    if request.method == 'POST':
        action = request.form.get('action')
        
        if action == 'cancelar':
            cancelacion_motivo = request.form.get('cancelacion_motivo')
            cita.cancelacion_motivo = cancelacion_motivo
            
            # Delegar al patrón State
            cita.cancelar()
            
            # Patrón Factory Method: Crear y enviar notificación
            from app.notificacion_factory import CreadorNotifEmail
            creador = CreadorNotifEmail()
            notificador = creador.crearNotificacion()
            mensaje = f"La cita para el {cita.fecha.strftime('%d/%m/%Y')} a las {cita.hora.strftime('%H:%M')} ha sido cancelada."
            notificador.enviar(mensaje, cita.paciente)
            
            db.session.commit()
            flash('La cita ha sido marcada como Cancelada.')
            
        elif action == 'aplicar':
            vacuna_id = request.form.get('vacuna_id')
            numero_dosis = request.form.get('numero_dosis')
            observaciones = request.form.get('observaciones')
            
            if not vacuna_id or not numero_dosis:
                flash('Debes seleccionar la vacuna y el número de dosis.')
                return redirect(url_for('process_cita', cita_id=cita.id))
                
            nueva_vacunacion = Vacunacion(
                fecha_aplicacion=datetime.now().date(),
                numero_dosis=int(numero_dosis),
                observaciones_reacciones=observaciones,
                vacuna_id=vacuna_id,
                especialista_id=especialista.id
            )
            db.session.add(nueva_vacunacion)
            db.session.flush() # To get the id for the cita
            
            # Delegar al patrón State
            cita.registrarVacunacion(nueva_vacunacion)
            
            # Reportar al Minsal usando el Controlador
            from app.controllers import ControladorVacunacion
            vacuna_obj = Vacuna.query.get(vacuna_id)
            if vacuna_obj:
                ControladorVacunacion.registrarDosis(cita.paciente.rut, vacuna_obj.id_minsal)
            
            # Patrón Factory Method: Crear y enviar notificación
            from app.notificacion_factory import CreadorNotifEmail
            creador = CreadorNotifEmail()
            notificador = creador.crearNotificacion()
            mensaje = f"Se ha completado exitosamente tu vacunación (Dosis {numero_dosis}) el {cita.fecha.strftime('%d/%m/%Y')}."
            notificador.enviar(mensaje, cita.paciente)
            
            db.session.commit()
            flash('¡La vacunación ha sido registrada exitosamente!')
            
        return redirect(url_for('especialista_dashboard'))
        
    return render_template('process_cita.html', title='Atender Cita', cita=cita, vacunas=vacunas)

@app.route('/organizador_dashboard')
@login_required
def organizador_dashboard():
    if session.get('role') != 'organizador':
        return redirect(url_for('index'))
    campanas = Campana.query.all()
    return render_template('organizador_dashboard.html', title='Panel de Organizador', campanas=campanas)

@app.route('/create_campana', methods=['GET', 'POST'])
@login_required
def create_campana():
    if session.get('role') != 'organizador':
        return redirect(url_for('index'))
        
    if request.method == 'POST':
        nombre = request.form.get('nombre_campana')
        enfermedad = request.form.get('enfermedad_objetivo')
        poblacion = request.form.get('poblacion_objetivo')
        fecha_inicio_str = request.form.get('fecha_inicio')
        fecha_fin_str = request.form.get('fecha_fin')
        
        try:
            fecha_inicio = datetime.strptime(fecha_inicio_str, '%Y-%m-%d').date()
            fecha_fin = datetime.strptime(fecha_fin_str, '%Y-%m-%d').date()
            
            nueva_campana = Campana(
                nombre_campana=nombre,
                enfermedad_objetivo=enfermedad,
                poblacion_objetivo=poblacion,
                fecha_inicio=fecha_inicio,
                fecha_fin=fecha_fin
            )
            db.session.add(nueva_campana)
            db.session.commit()
            flash('Campaña creada exitosamente.')
            return redirect(url_for('organizador_dashboard'))
        except Exception as e:
            flash(f'Error al crear campaña: {str(e)}')
            
    return render_template('campana_form.html', title='Crear Campaña', campana=None)

@app.route('/edit_campana/<int:id>', methods=['GET', 'POST'])
@login_required
def edit_campana(id):
    if session.get('role') != 'organizador':
        return redirect(url_for('index'))
        
    campana = Campana.query.get_or_404(id)
    
    if request.method == 'POST':
        campana.nombre_campana = request.form.get('nombre_campana')
        campana.enfermedad_objetivo = request.form.get('enfermedad_objetivo')
        campana.poblacion_objetivo = request.form.get('poblacion_objetivo')
        
        try:
            campana.fecha_inicio = datetime.strptime(request.form.get('fecha_inicio'), '%Y-%m-%d').date()
            campana.fecha_fin = datetime.strptime(request.form.get('fecha_fin'), '%Y-%m-%d').date()
            db.session.commit()
            flash('Campaña actualizada exitosamente.')
            return redirect(url_for('organizador_dashboard'))
        except Exception as e:
            flash(f'Error al actualizar campaña: {str(e)}')
            
    return render_template('campana_form.html', title='Editar Campaña', campana=campana)

@app.route('/delete_campana/<int:id>', methods=['POST'])
@login_required
def delete_campana(id):
    if session.get('role') != 'organizador':
        return redirect(url_for('index'))
        
    campana = Campana.query.get_or_404(id)
    try:
        db.session.delete(campana)
        db.session.commit()
        flash('Campaña eliminada exitosamente.')
    except Exception as e:
        flash(f'Error al eliminar campaña: {str(e)}')
        
    return redirect(url_for('organizador_dashboard'))

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
