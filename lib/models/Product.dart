class Product {
  final int id;
  final int categorieId;
  final String name;
  final String description;
  final String image;
  final double price;
  final DateTime created_at;
  final DateTime updated_at;

  Product copyWith({
    int? id,
    int? categorieId,
    String? name,
    String? description,
    String? image,
    double? price,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return Product(
      id: id ?? this.id,
      categorieId: categorieId ?? this.categorieId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Product({
    required this.id,
    required this.categorieId,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.created_at,
    required this.updated_at,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      categorieId: json['categorie_id'] as int? ?? 0,
      name: json['name'] ?? 'Nom inconnu',
      description: json['description'] ?? 'Pas de description',
      image: json['image'] ?? "Pas d'image",
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      created_at: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updated_at: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categorie_id': categorieId,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}
