const repo = require('../repositories/notesRepository');

async function listNotes() {
  return repo.getAllNotes();
}

async function addNote(data) {
  if (!data.title || !data.content) {
    throw new Error('title y content son obligatorios');
  }
  return repo.createNote(data.title, data.content);
}

module.exports = { listNotes, addNote };
