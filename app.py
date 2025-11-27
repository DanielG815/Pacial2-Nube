from flask import Flask, request, jsonify
import os
import psycopg2

app = Flask(__name__)

def get_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        dbname=os.getenv("DB_NAME", "todosdb"),
        user=os.getenv("DB_USER", "todosuser"),
        password=os.getenv("DB_PASSWORD", "secret")
    )

@app.route("/todos", methods=["GET"])
def get_todos():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, title FROM todos ORDER BY id")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify([{"id": r[0], "title": r[1]} for r in rows])

@app.route("/todos", methods=["POST"])
def create_todo():
    data = request.get_json()
    title = data.get("title")
    if not title:
        return jsonify({"error": "title is required"}), 400

    conn = get_conn()
    cur = conn.cursor()
    cur.execute("INSERT INTO todos (title) VALUES (%s) RETURNING id", (title,))
    todo_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"id": todo_id, "title": title}), 201

if __name__ == "__main__":
    # Para pruebas locales
    app.run(host="0.0.0.0", port=5000)
