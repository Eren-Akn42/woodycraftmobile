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

  void addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/products'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'categorie_id': product.categorieId,
        'description': product.description,
        'image': product.image,
      }),
    );

    if (response.statusCode == 201) {
      fetchProducts();
    }
  }

  void showAddProductDialog(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _priceController = TextEditingController();
    TextEditingController _categorieController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _imageController = TextEditingController();
    // Tu peux ajouter d'autres contrôleurs si nécessaire

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un nouveau produit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: "Nom du produit"),
                ),
                TextField(
                  controller: _priceController,
                  decoration:
                      const InputDecoration(hintText: "Prix du produit"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _categorieController,
                  decoration:
                      const InputDecoration(hintText: "Catégorie du produit"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(hintText: "Description du produit"),
                  maxLines:
                      null, // Permet de saisir plusieurs lignes si nécessaire
                ),
                TextField(
                  controller: _imageController,
                  decoration: const InputDecoration(hintText: "Nom de l'image"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                Product newProduct = Product(
                  id: 0, // L'ID sera généré par la base de données, donc pas nécessaire ici
                  name: _nameController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  categorieId: int.tryParse(_categorieController.text) ?? 0,
                  description: _descriptionController.text,
                  image: _imageController.text,
                  created_at:
                      DateTime.now(), // Ou laisser le serveur définir la date
                  updated_at:
                      DateTime.now(), // Ou laisser le serveur définir la date
                );

                // Appelle la fonction pour ajouter le produit
                addProduct(newProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                const SizedBox(height: 10),
                // Nom du produit
                Text(
                  'Nom: ${product.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 5),
                // Prix
                Text('Prix: ${product.price.toString()} €'),
                const SizedBox(height: 5),
                // Catégorie ID
                Text('Catégorie : ${product.categorieId}'),
                const SizedBox(height: 5),
                // Description
                Text('Description: ${product.description}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
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
      fetchProducts();
    }
  }

  void showEditDialog(Product product) {
    TextEditingController _nameController =
        TextEditingController(text: product.name);
    TextEditingController _priceController =
        TextEditingController(text: product.price.toString());
    TextEditingController _categorieController =
        TextEditingController(text: product.categorieId.toString());
    TextEditingController _descriptionController =
        TextEditingController(text: product.description);
    TextEditingController _imageController =
        TextEditingController(text: product.image);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier le produit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: "Nom du produit"),
                ),
                TextField(
                  controller: _priceController,
                  decoration:
                      const InputDecoration(hintText: "Prix du produit"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _categorieController,
                  decoration:
                      const InputDecoration(hintText: "Catégorie du produit"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(hintText: "Description du produit"),
                  maxLines: null,
                ),
                TextField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                      hintText: "Nom de l'image (format : {image}.png)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                Product updatedProduct = product.copyWith(
                  name: _nameController.text,
                  price:
                      double.tryParse(_priceController.text) ?? product.price,
                  categorieId: int.tryParse(_categorieController.text),
                  description: _descriptionController.text,
                  image: _imageController.text,
                );

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
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/products'));
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final Product product = products[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/${product.image}'),
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
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        showProductDetails(products[index]);
                      }),
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
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
                              title: const Text('Confirmation'),
                              content: const Text(
                                  'Voulez-vous vraiment supprimer ce produit ?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Annuler'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Supprimer'),
                                  onPressed: () {
                                    deleteProduct(product.id);
                                    Navigator.of(context).pop();
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
        onPressed: () => showAddProductDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
