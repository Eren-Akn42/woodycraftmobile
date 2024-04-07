const express = require('express');
const mysql = require('mysql');
const bcrypt = require('bcrypt');
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

app.delete('/products/:id', (req, res) => {
    const { id } = req.params;
    const query = 'DELETE FROM products WHERE id = ?';
    db.query(query, [id], (err, result) => {
        if (err) {
            console.error('Erreur lors de la suppression du produit :', err);
            res.status(500).send('Erreur lors de la suppression du produit');
            return;
        }
        if (result.affectedRows === 0) {
            res.status(404).send('Produit non trouvé');
            return;
        }
        res.status(200).send('Produit supprimé avec succès');
    });
});

app.put('/products/:id', (req, res) => {
    const { id } = req.params;
    const { name, price, categorie_id, description, image } = req.body;
    const query = 'UPDATE products SET name = ?, price = ?, categorie_id = ?, description = ?, image = ? WHERE id = ?';

    db.query(query, [name, price, categorie_id, description, image, id], (err, result) => {
        if (err) {
            console.error('Erreur lors de la mise à jour du produit :', err);
            res.status(500).send('Erreur lors de la mise à jour du produit');
            return;
        }
        if (result.affectedRows === 0) {
            res.status(404).send('Produit non trouvé');
            return;
        }
        res.status(200).send('Produit mis à jour avec succès');
    });
});

app.post('/products', (req, res) => {
    const { name, price, categorie_id, description, image } = req.body;
    const query = 'INSERT INTO products (name, price, categorie_id, description, image) VALUES (?, ?, ?, ?, ?)';

    db.query(query, [name, price, categorie_id, description, image], (err, result) => {
        if (err) {
            console.error('Erreur lors de la création du produit :', err);
            res.status(500).send('Erreur lors de la création du produit');
            return;
        }
        res.status(201).send(`Produit créé avec l'ID: ${result.insertId}`);
    });
});

app.post('/login', (req, res) => {
    const { username, password } = req.body;
    const query = 'SELECT * FROM admins WHERE username = ?';
    db.query(query, [username], (err, results) => {
        if (err) {
            console.error('Erreur lors de la vérification de l\'utilisateur:', err);
            return res.status(500).json({ success: false, message: "Erreur serveur" });
        }
        if (results.length > 0) {
            const user = results[0];
            bcrypt.compare(password, user.password, (err, isMatch) => {
                if (err) {
                    console.error('Erreur lors de la vérification du mot de passe:', err);
                    return res.status(500).json({ success: false, message: "Erreur serveur" });
                }
                if (isMatch) {
                    res.json({ success: true, message: "Authentification réussie" });
                } else {
                    res.status(401).json({ success: false, message: "Identifiants incorrects" });
                }
            });
        } else {
            res.status(401).json({ success: false, message: "Identifiants incorrects" });
        }
    });
});