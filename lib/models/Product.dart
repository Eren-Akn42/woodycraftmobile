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
      // Utilisation de DateTime.parse et gestion des cas où la date est absente
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categorie_id': categorie_id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      // Convertir les objets DateTime en String pour la sérialisation
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}
