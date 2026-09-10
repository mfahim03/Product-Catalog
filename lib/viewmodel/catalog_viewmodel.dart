import 'dart:async';

import '../model/product.dart';
import '../repository/product_repository.dart';

enum CatalogStatus { loading, success, empty, error }

/// Presentation logic and state for the catalogue view.
class CatalogViewModel {
  CatalogViewModel(this._repository);

  static const pageSize = 20;
  final ProductRepository _repository;
  ProductRepository get repository => _repository;

  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;

  CatalogStatus status = CatalogStatus.loading;
  List<Product> products = [];
  String query = '';
  String errorMessage = '';
  bool isLoadingMore = false;
  bool _hasMore = true;
  int _requestVersion = 0;

  Future<void> loadInitial() => _load(reset: true);

  Future<void> refresh() => _load(reset: true);

  Future<void> search(String value) {
    query = value.trim();
    return _load(reset: true);
  }

  Future<void> loadMore() => _load(reset: false);

  Future<void> _load({required bool reset}) async {
    if (!reset && (isLoadingMore || !_hasMore || status == CatalogStatus.loading)) return;

    final version = reset ? ++_requestVersion : _requestVersion;
    if (reset) {
      status = CatalogStatus.loading;
      errorMessage = '';
      _hasMore = true;
    } else {
      isLoadingMore = true;
    }
    _notify();

    try {
      final page = await _repository.fetchProducts(
        skip: reset ? 0 : products.length,
        limit: pageSize,
        query: query,
      );
      if (version != _requestVersion) return;
      products = reset ? page.products : [...products, ...page.products];
      _hasMore = products.length < page.total && page.products.isNotEmpty;
      status = products.isEmpty ? CatalogStatus.empty : CatalogStatus.success;
    } catch (error) {
      if (version != _requestVersion) return;
      if (reset) {
        status = CatalogStatus.error;
        errorMessage = error.toString();
      }
    } finally {
      if (version == _requestVersion) {
        isLoadingMore = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  void dispose() => _changes.close();
}
