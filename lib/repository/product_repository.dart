import '../model/product.dart';
import '../service/dummyJson_api.dart';

class ProductRepository {
  ProductRepository(this._api);
  final DummyJsonApi _api;

  Future<ProductPage> fetchProducts({required int skip, required int limit, String query = ''}) =>
      _api.getProducts(skip: skip, limit: limit, query: query);
  Future<Product> fetchProduct(int id) => _api.getProduct(id);
}
