class Product {
  final int id;
  final int categorie_id;
  final String name;
  final String description;
  final String image;
  final double price;
  final DateTime created_at;
  final DateTime updated_at;

  Product({
    required this.id,
    required this.categorie_id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.created_at,
    required this.updated_at,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categorie_id: json['categorie_id'],
      name: json['name'] ?? 'Nom inconnu',
      description: json['description'] ?? 'Pas de description',
      image: json['image'] ?? "Pas d'image",
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      created_at: json['created_at'] ?? 'Pas de date de création',
      updated_at: json['updated_at'] ?? 'Pas de date de mise à jour',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'quantite_en_stock': quantiteEnStock,
    };
  }
}
