import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'models/Product.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchProducts();
    });
  }

  fetchProducts() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/products'));
    if (response.statusCode == 200) {
      final List<Product> loadedProducts = (json.decode(response.body) as List)
          .map((data) => Product.fromJson(data))
          .toList();
      setState(() {
        products = loadedProducts;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des produits')),
      );
    }
  }

  void addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/products'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du produit')),
      );
    }
  }

  void showAddProductDialog(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _priceController = TextEditingController();
    TextEditingController _categorieController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _imageController = TextEditingController();
    TextEditingController _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un nouveau produit'),
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
                ),
                TextField(
                  controller: _descriptionController,
                  decoration:
                      InputDecoration(hintText: "Description du produit"),
                ),
                TextField(
                  controller: _imageController,
                  decoration: InputDecoration(hintText: "Nom de l'image"),
                ),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(hintText: "Quantité"),
                  keyboardType: TextInputType.number,
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
              child: Text('Ajouter'),
              onPressed: () {
                if (_nameController.text.isEmpty ||
                    _priceController.text.isEmpty ||
                    _categorieController.text.isEmpty ||
                    _descriptionController.text.isEmpty ||
                    _imageController.text.isEmpty ||
                    _quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Tous les champs sont obligatoires')),
                  );
                } else {
                  Product newProduct = Product(
                    id: 0,
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    categorieId: int.parse(_categorieController.text),
                    description: _descriptionController.text,
                    image: _imageController.text,
                    quantity: int.parse(_quantityController.text),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  addProduct(newProduct);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showProductDetails(Product product) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            product.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.asset(
                  'assets/${product.image}',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported);
                  },
                ),
                SizedBox(height: 10),
                Text('Catégorie : ${product.categorieId}'),
                SizedBox(height: 10),
                Text('Prix : ${product.price.toString()} €'),
                SizedBox(height: 10),
                Text('Quantité : ${product.quantity}'),
                SizedBox(height: 10),
                Text('Description : ${product.description}'),
                SizedBox(height: 10),
                Text('Créé le : ${dateFormat.format(product.createdAt)}'),
                SizedBox(height: 10),
                Text('Mis à jour le : ${dateFormat.format(product.updatedAt)}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des produits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              leading: Image.asset(
                'assets/${product.image}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: Icon(Icons.image, color: Colors.grey)),
                  );
                },
              ),
              title: Text(
                product.name,
                style: TextStyle(color: Colors.black),
              ),
              subtitle: Text(
                'Catégorie: ${product.categorieId}\n${product.price} €',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () => showProductDetails(product),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showEditDialog(context, product),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.blue),
                    onPressed: () => deleteProduct(product.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddProductDialog(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void showEditDialog(BuildContext context, Product product) {
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
    TextEditingController _quantityController =
        TextEditingController(text: product.quantity.toString());

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
                  controller: _quantityController,
                  decoration: InputDecoration(hintText: "Quantité"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _categorieController,
                  decoration: InputDecoration(hintText: "Catégorie du produit"),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration:
                      InputDecoration(hintText: "Description du produit"),
                ),
                TextField(
                  controller: _imageController,
                  decoration: InputDecoration(hintText: "Image du produit"),
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
              child: Text('Modifier'),
              onPressed: () {
                Product updatedProduct = Product(
                  id: product.id,
                  name: _nameController.text,
                  price: double.parse(_priceController.text),
                  categorieId: int.parse(_categorieController.text),
                  description: _descriptionController.text,
                  image: _imageController.text,
                  quantity: int.parse(_quantityController.text),
                  createdAt: product.createdAt,
                  updatedAt: DateTime.now(),
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

  void deleteProduct(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer'),
          content: Text('Voulez-vous vraiment supprimer ce produit ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/products/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          products.removeWhere((product) => product.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit supprimé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression du produit')),
        );
      }
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du produit')),
      );
    }
  }
}
