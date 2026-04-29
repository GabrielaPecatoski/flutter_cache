import '../../domain/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({bool forceRefresh = false});
}
