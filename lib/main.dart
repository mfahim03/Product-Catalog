import 'package:flutter/material.dart';

import 'repository/product_repository.dart';
import 'service/dummyJson_api.dart';
import 'viewmodel/catalog_viewmodel.dart';
import 'view/catalog_page.dart';

void main() => runApp(const ProductCatalogApp());

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Catalogue',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.light,
            surface: const Color(0xFFF7F6F2),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F6F2),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F6F2),
            foregroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          dividerColor: Colors.black,
          textTheme: const TextTheme(
            headlineSmall: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w400),
            titleLarge: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w400),
          ),
          useMaterial3: true,
        ),
        home: CatalogPage(
          controller: CatalogViewModel(ProductRepository(DummyJsonApi())),
        ),
      );
}
