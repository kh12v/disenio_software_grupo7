# Diseño de Software (Grupo 7)

## Entrega Final

## 💻 Instalación y ejecución (Windows)

### 1. Clonar el repositorio
Abre tu terminal (se recomienda en VSCode) y ejecuta:

```powershell
git clone https://github.com/kh12v/disenio_software_grupo7.git
cd disenio_software_grupo7/tuvacunaApp
```

### 2. Crear y activar el entorno virtual
Para evitar problemas de dependencias, es necesario crear un entorno virtual antes de ejecutar el proyecto.

```powershell
# Crear el entorno virtual (solo se hace la primera vez)
python -m venv venv

# Activar el entorno virtual (Por defecto en VSCode)
.\venv\Scripts\activate
```

### 3. Configurar variables de entorno
El proyecto utiliza la API de Resend para el envío de correos. Debes configurar tu clave:

1. Asegurate de estar en la misma carpeta que `run.py`. Crea un archivo llamado `.env`.
2. Pega tu API Key dentro del archivo. **Importante:** El archivo .env está incluido en el .gitignore para no subir las credenciales al repositorio.

### 4. Instalar las dependencias

```powershell
pip install -r requirements.txt
```

### 5. Ejecutar la aplicación (Dos consolas)
Para que el proyecto funcione correctamente, necesitas ejecutar dos consolas en paralelo. En VSCode, puedes dividir tu terminal en dos paneles e ingresar un comando en cada uno (asegúrate de que el entorno virtual (venv) esté activo en ambas paneles):

- **Panel 1 (Programa principal):**

```powershell
python run.py
```

- **Panel 2 (Compilador de TailwindCSS):**

```powershell
tailwindcss --watch -i app/static/css/input.css -o app/static/css/output.css
```

El servidor quedará corriendo en modo local. Puedes acceder a la aplicación web en [http://127.0.0.1:5000](http://127.0.0.1:5000).