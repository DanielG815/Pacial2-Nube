-- Crear tabla de notas
CREATE TABLE IF NOT EXISTS notes (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Crear índice para búsquedas más rápidas
CREATE INDEX IF NOT EXISTS idx_notes_created_at ON notes(created_at DESC);

-- Crear tabla de auditoría (opcional)
CREATE TABLE IF NOT EXISTS audit_log (
  id SERIAL PRIMARY KEY,
  action VARCHAR(50) NOT NULL,
  table_name VARCHAR(50) NOT NULL,
  record_id INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
