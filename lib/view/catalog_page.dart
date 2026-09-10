import 'dart:async';

import 'package:flutter/material.dart';

import '../../model/product.dart';
import '../../viewmodel/catalog_viewmodel.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.controller});
  final CatalogViewModel controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final StreamSubscription<void> _subscription;
  late final ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subscription = widget.controller.changes.listen((_) {
      if (mounted) setState(() {});
    });
    _scrollController = ScrollController()..addListener(_onScroll);
    widget.controller.loadInitial();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 400) widget.controller.loadMore();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => widget.controller.search(value));
  }

  Future<void> _returnToTop() async {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
    if (mounted) await widget.controller.refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription.cancel();
    _scrollController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            _StoreHeader(onCatalogTap: _returnToTop),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 13, letterSpacing: .6),
                decoration: const InputDecoration(
                  hintText: 'SEARCH THE CATALOG',
                  hintStyle: TextStyle(fontSize: 12, letterSpacing: 1.1, color: Colors.black54),
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 2)),
                ),
              ),
            ),
            Expanded(child: _body()),
          ]),
        ),
      );

  Widget _body() {
    final controller = widget.controller;
    switch (controller.status) {
      case CatalogStatus.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.black));
      case CatalogStatus.error:
        return _MessageState(
          title: 'UNABLE TO LOAD PRODUCTS',
          description: controller.errorMessage,
          action: OutlinedButton(onPressed: controller.loadInitial, child: const Text('RETRY')),
        );
      case CatalogStatus.empty:
        return const _MessageState(title: 'NO PRODUCTS FOUND', description: 'Try a different search term.');
      case CatalogStatus.success:
        return LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 700 ? 3 : 2;
          return RefreshIndicator(
            color: Colors.black,
            onRefresh: controller.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _CollectionBar(count: controller.products.length, query: controller.query)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == controller.products.length) return const Center(child: CircularProgressIndicator(color: Colors.black));
                        final product = controller.products[index];
                        return _ProductCard(
                          product: product,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: product, repository: controller.repository),
                          )),
                        );
                      },
                      childCount: controller.products.length + (controller.isLoadingMore ? 1 : 0),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 24,
                      childAspectRatio: .61,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    }
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.onCatalogTap});
  final VoidCallback onCatalogTap;

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 17),
          child: Row(children: [
            const Icon(Icons.menu, size: 22),
            const Spacer(),
            GestureDetector(
              onTap: onCatalogTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text('THE CATALOG', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2.4, fontSize: 18)),
              ),
            ),
            const Spacer(),
            const Icon(Icons.shopping_bag_outlined, size: 20),
          ]),
        ),
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Text('ALL PRODUCTS', style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            Spacer(),
            Text('USD', style: TextStyle(fontSize: 11, letterSpacing: 1.3)),
          ]),
        ),
        const Divider(height: 1),
      ]);
}

class _CollectionBar extends StatelessWidget {
  const _CollectionBar({required this.count, required this.query});
  final int count;
  final String query;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Row(children: [
          Expanded(child: Text(query.isEmpty ? 'ALL PRODUCTS' : 'SEARCH RESULTS', style: const TextStyle(fontSize: 12, letterSpacing: 1.4, fontWeight: FontWeight.w700))),
          Text('$count ITEMS', style: const TextStyle(fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(width: 18),
          const Text('SORT +', style: TextStyle(fontSize: 11, letterSpacing: 1.2)),
        ]),
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.title, required this.description, this.action});
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: const TextStyle(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(description, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ]),
        ),
      );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _ProductImage(url: product.thumbnail)),
          const SizedBox(height: 9),
          Text(product.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, height: 1.25, letterSpacing: .45, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, letterSpacing: .35)),
        ]),
      );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xFFEAE9E4),
        child: SizedBox.expand(
          child: url.isEmpty
              ? const Icon(Icons.image_outlined)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5)),
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                ),
        ),
      );
}
