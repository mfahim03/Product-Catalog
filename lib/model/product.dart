class Product {
  const Product({required this.id, required this.title, required this.description, required this.price, required this.rating, required this.thumbnail, required this.images});
  final int id;
  final String title;
  final String description;
  final num price;
  final num rating;
  final String thumbnail;
  final List<String> images;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String? ?? 'Untitled product',
        description: json['description'] as String? ?? '',
        price: json['price'] as num? ?? 0,
        rating: json['rating'] as num? ?? 0,
        thumbnail: json['thumbnail'] as String? ?? '',
        images: (json['images'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      );
}

class ProductPage {
  const ProductPage({required this.products, required this.total});
  final List<Product> products;
  final int total;

  factory ProductPage.fromJson(Map<String, dynamic> json) => ProductPage(
        products: (json['products'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().map(Product.fromJson).toList(),
        total: json['total'] as int? ?? 0,
      );
}
