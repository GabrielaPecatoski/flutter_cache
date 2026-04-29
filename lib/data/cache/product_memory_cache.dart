import '../../domain/models/product.dart';

class ProductMemoryCache {
  static final ProductMemoryCache _instance = ProductMemoryCache._();
  factory ProductMemoryCache() => _instance;
  ProductMemoryCache._();

  List<Product>? _products;
  DateTime? _cachedAt;
  final Duration _ttl = const Duration(minutes: 5);

  bool get isValid {
    if (_products == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) < _ttl;
  }

  List<Product>? get products => isValid ? _products : null;

  void set(List<Product> products) {
    _products = products;
    _cachedAt = DateTime.now();
  }

  void invalidate() {
    _products = null;
    _cachedAt = null;
  }
}
