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
  List products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/products'));

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
        title: Text('Produits'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final Product product = products[index] as Product;
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Prix: ${product.price.toString()} €'),
          );
        },
      ),
    );
  }
}
