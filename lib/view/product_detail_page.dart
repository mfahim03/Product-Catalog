import 'package:flutter/material.dart';

import '../../model/product.dart';
import '../../repository/product_repository.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product, required this.repository});

  final Product product;
  final ProductRepository repository;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(product.title)),
        body: FutureBuilder<Product>(
          future: repository.fetchProduct(product.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _DetailError(product: product, repository: repository);
            }
            return _ProductDetail(product: snapshot.data ?? product);
          },
        ),
      );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.product, required this.repository});
  final Product product;
  final ProductRepository repository;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, size: 45),
            const SizedBox(height: 12),
            const Text('Could not load the latest product details.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product, repository: repository),
              )),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
}

class _ProductDetail extends StatelessWidget {
  const _ProductDetail({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          SizedBox(
            height: 260,
            child: PageView.builder(
              itemCount: product.images.isEmpty ? 1 : product.images.length,
              itemBuilder: (_, index) => _ProductImage(
                url: product.images.isEmpty ? product.thumbnail : product.images[index],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(children: [
            Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            const Icon(Icons.star_rounded, color: Colors.amber),
            Text(' ${product.rating.toStringAsFixed(1)}'),
          ]),
          const SizedBox(height: 24),
          Text('About this product', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(product.description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: url.isEmpty
            ? const ColoredBox(color: Color(0xFFE2E8F0), child: Icon(Icons.image_not_supported_outlined, size: 48))
            : Image.network(url, fit: BoxFit.cover, loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(color: Color(0xFFE2E8F0), child: Center(child: CircularProgressIndicator()));
              }, errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE2E8F0), child: Icon(Icons.broken_image_outlined, size: 48),
              )),
      );
}
