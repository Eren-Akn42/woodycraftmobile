import 'package:flutter/material.dart';
import 'products.dart';
import 'stocks.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return ProductsPage();
      case 1:
        return StocksPage();
      default:
        return Center(child: Text('Page non trouvée'));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List<Widget>.generate(2, (index) => _getPage(index)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Stocks',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
