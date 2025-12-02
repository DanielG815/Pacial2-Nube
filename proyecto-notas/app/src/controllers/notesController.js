const service = require('../services/notesService');

async function getNotes(req, res) {
  try {
    const notes = await service.listNotes();
    res.json(notes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

async function postNote(req, res) {
  try {
    const note = await service.addNote(req.body);
    res.status(201).json(note);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

module.exports = { getNotes, postNote };
