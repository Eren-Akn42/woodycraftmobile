const mysql = require('mysql');
const bcrypt = require('bcrypt');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'woodycraftweb'
});

connection.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à la base de données :', err);
    return;
  }
  console.log('Connecté à la base de données MySQL');
});

const adminData = {
  username: 'eren',
  password: 'password',
};

// Utilisation de bcrypt pour hasher le mot de passe
bcrypt.hash(adminData.password, 10, (err, hash) => {
  if (err) {
    console.error('Erreur lors du hachage du mot de passe :', err);
    return;
  }
  adminData.password = hash; // Remplacer le mot de passe non crypté par le hash
  // Requête SQL pour insérer l'administrateur
  const sql = 'INSERT INTO admins SET ?';
  connection.query(sql, adminData, (err, results) => {
    if (err) {
      console.error('Erreur lors de l\'insertion de l\'administrateur :', err);
      return;
    }
    console.log('Administrateur inséré avec succès !');
    // Fermeture de la connexion à la base de données après l'exécution de la requête
    connection.end();
  });
});
