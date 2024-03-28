const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());

// Middleware pour parser le corps des requêtes en JSON
app.use(express.json());

// Configuration de la connexion à la base de données
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'woodycraftweb'
});

db.connect((err) => {
    if (err) throw err;
    console.log('Connecté à la base de données MySQL !');
});

// Définition d'une route simple pour tester
app.get('/', (req, res) => {
    res.send('Hello World!');
});
  
app.listen(port, () => {
    console.log(`Serveur démarré sur http://localhost:${port}`);
});

app.get('/products', (req, res) => {
    const query = 'SELECT * FROM products';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erreur lors de la récupération des produits :', err);
            res.status(500).send('Erreur lors de la récupération des produits');
            return;
        }
        res.json(results);
    });
});