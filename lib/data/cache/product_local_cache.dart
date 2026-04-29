import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/product.dart';

class ProductLocalCache {
  static const _keyProducts = 'cached_products';
  static const _keyTimestamp = 'cached_products_at';
  final Duration _ttl = const Duration(hours: 1);

  final SharedPreferences _prefs;

  ProductLocalCache(this._prefs);

  bool get isValid {
    final ts = _prefs.getInt(_keyTimestamp);
    if (ts == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cachedAt) < _ttl;
  }

  Future<List<Product>?> get() async {
    if (!isValid) return null;
    final raw = _prefs.getString(_keyProducts);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> set(List<Product> products) async {
    final encoded = jsonEncode(products.map((p) => p.toMap()).toList());
    await _prefs.setString(_keyProducts, encoded);
    await _prefs.setInt(
      _keyTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> invalidate() async {
    await _prefs.remove(_keyProducts);
    await _prefs.remove(_keyTimestamp);
  }
}
