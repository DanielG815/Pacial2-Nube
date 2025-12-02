const express = require('express');
const controller = require('../controllers/notesController');
const router = express.Router();

router.get('/notes', controller.getNotes);
router.post('/notes', controller.postNote);

module.exports = router;
