class Product {
  final int id;
  final String name;
  final double price;
  final int categorieId;
  final String description;
  final String image;
  final int quantity; // Nouvelle propriété ajoutée
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.categorieId,
    required this.description,
    required this.image,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      categorieId: json['categorie_id'],
      description: json['description'],
      image: json['image'],
      quantity: json['quantity'], // Ajout de la quantité depuis JSON
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'categorie_id': categorieId,
      'description': description,
      'image': image,
      'quantity': quantity, // Inclure la quantité dans le JSON
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? categorieId,
    String? description,
    String? image,
    int? quantity, // Permettre la modification de la quantité
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categorieId: categorieId ?? this.categorieId,
      description: description ?? this.description,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity, // Copie de la quantité
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
