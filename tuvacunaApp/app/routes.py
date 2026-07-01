from flask import render_template, redirect, url_for, flash, request
from app import app, db
from app.models import User
from flask_login import current_user, login_user, logout_user, login_required
from urllib.parse import urlsplit
import re

@app.route('/')
@app.route('/index')
@login_required
def index():
    return render_template('index.html', title='Inicio')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    if request.method == 'POST':
        rut = request.form['rut']
        if not re.match(r'^\d{1,2}\.\d{3}\.\d{3}-[\dkK]$', rut):
            flash('Formato de RUT inválido')
            return redirect(url_for('login'))
        user = User.query.filter_by(rut=rut).first()
        if user is None or not user.check_password(request.form['password']):
            flash('RUT o clave única inválidos')
            return redirect(url_for('login'))
        login_user(user, remember='remember_me' in request.form)
        next_page = request.args.get('next')
        if not next_page or urlsplit(next_page).netloc != '':
            next_page = url_for('index')
        return redirect(next_page)
    return render_template('login.html', title='Iniciar sesión')

@app.route('/logout')
def logout():
    logout_user()
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
        user = User.query.filter_by(rut=rut).first()
        if user is not None:
            flash('Por favor usa un RUT diferente.')
            return redirect(url_for('register'))
        user = User.query.filter_by(email=request.form['email']).first()
        if user is not None:
            flash('Por favor usa un correo electrónico diferente.')
            return redirect(url_for('register'))
            
        user = User(rut=rut, email=request.form['email'], role='patient')
        user.set_password(request.form['password'])
        db.session.add(user)
        db.session.commit()
        flash('¡Felicidades, te has registrado exitosamente!')
        return redirect(url_for('login'))
    return render_template('register.html', title='Registro')
