class AffiliateProduct {
  final int id;
  final String name;
  final String? category;
  final String amazonUrl;
  final String? imageUrl;
  AffiliateProduct({required this.id, required this.name, this.category, required this.amazonUrl, this.imageUrl});
  factory AffiliateProduct.fromJson(Map<String, dynamic> j) => AffiliateProduct(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        category: j['category'] as String?,
        amazonUrl: (j['amazon_url'] ?? '') as String,
        imageUrl: j['image_url'] as String?,
      );
}

