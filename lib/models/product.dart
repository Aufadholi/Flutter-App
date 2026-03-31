
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final img = (images != null && images.isNotEmpty) ? images.first.toString() : 'https://via.placeholder.com/150';
    final categoryObj = json['category'];
    final categoryName = categoryObj is Map<String, dynamic> ? (categoryObj['name']?.toString() ?? 'Unknown') : (categoryObj?.toString() ?? 'Unknown');

    return Product(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: img,
      category: categoryName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
      };
}
