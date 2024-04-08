import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/Product.dart';

class StocksPage extends StatefulWidget {
  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchLowStockProducts();
  }

  fetchLowStockProducts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/products/lowstock'));
    if (response.statusCode == 200) {
      setState(() {
        products = (json.decode(response.body) as List)
            .map((data) => Product.fromJson(data))
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors du chargement des produits à faible stock')),
      );
    }
  }

  void increaseStock(Product product, int amount) async {
    final newQuantity = product.quantity + amount;
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/products/${product.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'categorie_id': product.categorieId,
        'description': product.description,
        'image': product.image,
        'quantity': newQuantity,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock mis à jour avec succès')),
      );
      setState(() {
        products = products.map((p) {
          if (p.id == product.id) {
            return p.copyWith(quantity: newQuantity);
          }
          return p;
        }).toList();
        products = products.where((p) => p.quantity <= 5).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du stock')),
      );
    }
  }

  void showIncreaseStockDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Augmenter le stock de ${product.name}'),
          content: SingleChildScrollView(
            // Utilisez un SingleChildScrollView
            child: Column(
              // Remplacez GridView par Column
              mainAxisSize: MainAxisSize.min,
              children: <int>[5, 10, 20, 50, 100].map((int value) {
                return ElevatedButton(
                  onPressed: () {
                    increaseStock(product, value);
                    Navigator.of(context).pop();
                  },
                  child: Text('$value'),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
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
          'Gestion des stocks',
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
                'assets/${product.image}', // Ajustez cette ligne en fonction du nom du fichier dans vos assets
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, color: Colors.grey);
                },
              ),
              title: Text(product.name),
              trailing: Text(
                '${product.quantity}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Taille de police plus grande pour la quantité
                ),
              ),
              onTap: () => showIncreaseStockDialog(product),
            ),
          );
        },
      ),
    );
  }
}
