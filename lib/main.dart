import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/Product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Produits',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductsPage(),
    );
  }
}

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];

  void showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Détails du produit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Image en format 1:1
                Center(
                  child: Image.asset(
                    'assets/${product.image}',
                    width: 300.0,
                    height: 300.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                // Nom du produit
                Text(
                  'Nom: ${product.name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 5), // Espace entre les éléments
                // Prix
                Text('Prix: ${product.price.toString()} €'),
                SizedBox(height: 5),
                // Catégorie ID
                Text('Catégorie : ${product.categorieId}'),
                SizedBox(height: 5),
                // Description
                Text('Description: ${product.description}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  void deleteProduct(int id) async {
    final response =
    await http.delete(Uri.parse('http://10.0.2.2:3000/products/$id'));

    if (response.statusCode == 200) {
      setState(() {
        products.removeWhere((product) => product.id == id);
      });
    }
  }

  void updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/products/${product.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      // Si le serveur retourne un succès, rafraîchir l'interface utilisateur
      fetchProducts();
    } else {
      // Si le serveur ne retourne pas un succès, afficher un message d'erreur
      // TODO: implémentez une gestion d'erreur appropriée
    }
  }

  void showEditDialog(Product product) {
    TextEditingController _nameController = TextEditingController(text: product.name);
    TextEditingController _priceController = TextEditingController(text: product.price.toString());
    TextEditingController _categorieController = TextEditingController(text: product.categorieId.toString());
    TextEditingController _descriptionController = TextEditingController(text: product.description);
    // Ajoute d'autres contrôleurs si nécessaire

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le produit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Nom du produit"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(hintText: "Prix du produit"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _categorieController,
                  decoration: InputDecoration(hintText: "Catégorie du produit"),
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(hintText: "Description du produit"),
                  maxLines: null, // Permet de saisir plusieurs lignes si nécessaire
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                // Mise à jour de la création d'un nouvel objet produit avec les données mises à jour
                Product updatedProduct = product.copyWith(
                  name: _nameController.text,
                  price: double.tryParse(_priceController.text) ?? product.price,
                  categorieId: int.tryParse(_categorieController.text),
                  description: _descriptionController.text,
                );

                // Mise à jour du produit
                updateProduct(updatedProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/products'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;
      setState(() {
        products =
            data.map((productJson) => Product.fromJson(productJson)).toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des produits',
          style: TextStyle(
            color: Colors.white, // Met le texte en blanc
            fontWeight: FontWeight.bold, // Rend le texte gras
          ),
        ),
        centerTitle: true, // Centre le titre dans l'AppBar
        backgroundColor:
            Colors.blue, // S'assure que la couleur de fond est bleue
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final Product product = products[index];
          return Card( // J'ai utilisé un Card pour un meilleur design
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/${product.image}'), // Assure-toi que l'image existe dans le dossier assets
                backgroundColor: Colors.transparent,
              ),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Catégorie: ${product.categorieId}'),
                  Text('Prix: ${product.price.toString()} €'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        showProductDetails(products[index]);
                      }),
                  IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showEditDialog(products[index]);
                      }),
                  IconButton(
                      icon: Icon(Icons.delete, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Voulez-vous vraiment supprimer ce produit ?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Annuler'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Fermer le dialogue
                                  },
                                ),
                                TextButton(
                                  child: Text('Supprimer'),
                                  onPressed: () {
                                    deleteProduct(product.id); // Appeler la fonction de suppression
                                    Navigator.of(context).pop(); // Fermer le dialogue
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add your onPressed code here!
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}