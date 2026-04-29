import 'package:flutter/foundation.dart';

import '../../data/repositories/product_repository.dart';
import '../../domain/models/product.dart';

enum ProductListStateStatus { idle, loading, refreshing, success, empty, error }

class ProductListState {
  final ProductListStateStatus status;
  final List<Product> products;
  final String? errorMessage;

  const ProductListState({
    required this.status,
    this.products = const [],
    this.errorMessage,
  });

  ProductListState copyWith({
    ProductListStateStatus? status,
    List<Product>? products,
    String? errorMessage,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductListViewModel(this._repository);

  ProductListState _state = const ProductListState(
    status: ProductListStateStatus.idle,
  );

  ProductListState get state => _state;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    final isRefresh =
        forceRefresh && _state.status == ProductListStateStatus.success;

    _state = _state.copyWith(
      status: isRefresh
          ? ProductListStateStatus.refreshing
          : ProductListStateStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final products =
          await _repository.getProducts(forceRefresh: forceRefresh);

      _state = _state.copyWith(
        status: products.isEmpty
            ? ProductListStateStatus.empty
            : ProductListStateStatus.success,
        products: products,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: ProductListStateStatus.error,
        errorMessage: 'Falha ao carregar produtos: $e',
      );
    }

    notifyListeners();
  }
}
