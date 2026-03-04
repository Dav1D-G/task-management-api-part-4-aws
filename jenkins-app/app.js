const express = require('express');

const app = express();

app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

const tasks = [
  { id: 1, title: 'First task', done: false },
  { id: 2, title: 'Second task', done: true }
];

app.get('/tasks', (req, res) => {
  res.status(200).json(tasks);
});

if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Task Management API listening on port ${port}`);
  });
}

module.exports = app;
