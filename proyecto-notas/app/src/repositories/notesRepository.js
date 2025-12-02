const db = require('../db/connection');

async function getAllNotes() {
  const result = await db.query('SELECT * FROM notes ORDER BY created_at DESC');
  return result.rows;
}

async function createNote(title, content) {
  const result = await db.query(
    'INSERT INTO notes (title, content, created_at) VALUES ($1, $2, NOW()) RETURNING *',
    [title, content]
  );
  return result.rows[0];
}

module.exports = { getAllNotes, createNote };
