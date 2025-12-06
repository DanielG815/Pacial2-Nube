import os
import time
import psycopg2
from flask import Flask

app = Flask(__name__)

# Configuración de conexión a la Base de Datos
def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get('DB_HOST', 'localhost'),
        database=os.environ.get('DB_NAME', 'postgres'),
        user=os.environ.get('DB_USER', 'postgres'),
        password=os.environ.get('DB_PASSWORD', 'password')
    )
    return conn

@app.route('/')
def hello():
    conn = get_db_connection()
    cur = conn.cursor()
    # Crear tabla si no existe
    cur.execute('CREATE TABLE IF NOT EXISTS visitas (id SERIAL PRIMARY KEY, count INT);')
    cur.execute('INSERT INTO visitas (count) VALUES (1);')
    conn.commit()
    
    # Contar visitas
    cur.execute('SELECT count(*) FROM visitas;')
    total = cur.fetchone()[0]
    
    cur.close()
    conn.close()
    return f"¡Hola desde Kubernetes! Esta página ha sido visitada {total} veces."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)