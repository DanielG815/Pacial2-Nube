const express = require('express');
const notesRoutes = require('./routes/notesRoutes');

const app = express();
app.use(express.json());
app.use('/api', notesRoutes);

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`API escuchando en puerto ${port}`);
});
