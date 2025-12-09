import os
import psycopg2
from flask import Flask, render_template

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get('DB_HOST', 'postgres-service'),
        database=os.environ.get('DB_NAME', 'postgres'),
        user=os.environ.get('DB_USER', 'postgres'),
        password=os.environ.get('DB_PASSWORD', 'password')
    )
    return conn

@app.route('/')
def hello():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('CREATE TABLE IF NOT EXISTS visitas (id SERIAL PRIMARY KEY, count INT);')
        cur.execute('INSERT INTO visitas (count) VALUES (1);')
        conn.commit()
        
        cur.execute('SELECT count(*) FROM visitas;')
        total = cur.fetchone()[0]
        
        cur.close()
        conn.close()
        
        # AQUÍ ESTÁ EL CAMBIO: Usamos la plantilla HTML
        return render_template('index.html', count=total)
        
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)