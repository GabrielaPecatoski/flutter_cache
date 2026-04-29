import '../../domain/models/product.dart';
import '../cache/product_local_cache.dart';
import '../cache/product_memory_cache.dart';
import '../datasources/product_api.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApi _api;
  final ProductMemoryCache _memoryCache;
  final ProductLocalCache _localCache;

  ProductRepositoryImpl({
    required ProductApi api,
    required ProductMemoryCache memoryCache,
    required ProductLocalCache localCache,
  })  : _api = api,
        _memoryCache = memoryCache,
        _localCache = localCache;

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final memory = _memoryCache.products;
      if (memory != null) return memory;

      final local = await _localCache.get();
      if (local != null) {
        _memoryCache.set(local);
        return local;
      }
    }

    final products = await _api.fetchProducts();
    _memoryCache.set(products);
    await _localCache.set(products);
    return products;
  }
}
