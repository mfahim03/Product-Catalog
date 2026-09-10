import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/model/product.dart';

void main() {
  test('ProductPage parses safe defaults from an API response', () {
    final page = ProductPage.fromJson({
      'total': 1,
      'products': [
        {'id': 7, 'title': 'Phone', 'price': 99.5, 'images': ['https://image.test/1.png']}
      ],
    });

    expect(page.total, 1);
    expect(page.products.single.title, 'Phone');
    expect(page.products.single.rating, 0);
    expect(page.products.single.images, ['https://image.test/1.png']);
  });
}
