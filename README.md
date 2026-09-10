# Product Catalog

A Flutter product catalog built for the Neurogine Junior Mobile Developer technical assessment. It uses the free [DummyJSON Products API](https://dummyjson.com/docs/products)

## Stack

- Flutter and Dart
- `http` for network requests
- Material 3 widgets

## Run locally

Pre-requisites: Flutter SDK 3.12 or newer, Android emulator/device, Windows desktop or Chrome.

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
```

## Assessment requirements

| Requirement | Implementation |
| --- | --- |
| Product list | Responsive product grid with each item's thumbnail, title, and price. |
| Pagination | Loads 20 products at a time and passes the loaded-item count as DummyJSON's `skip` parameter. |
| Product detail | Fetches `/products/{id}` and shows the description, price, rating, and swipeable images. |
| States | Separate loading, retryable error, empty-search, and success states. |
| Search | 400 ms debounced, server-side search via `/products/search?q=...`. |
| Code organisation | Separate model, service, repository, and presentation layers. |

### Extras

- Pull-to-refresh
- Image loading and error placeholders
- A data-model parsing test
- Tapping **THE CATALOG** scrolls the grid to the top and refreshes it

## API usage

The app uses these endpoints:

- List: `GET /products?limit=20&skip={skip}`
- Detail: `GET /products/{id}`
- Search: `GET /products/search?q={query}&limit=20&skip={skip}`

Search is server-side instead of client-side because the app intentionally loads products in pages. Filtering only the products already held in memory would omit matches from later pages; the search endpoint searches the complete catalog and still supports pagination.

## Architecture

```text
CatalogPage / ProductDetailPage
              ↓
      CatalogViewModel
              ↓
      ProductRepository
              ↓
         DummyJsonApi
              ↓
          DummyJSON API
```

- `lib/model/product.dart` — immutable `Product` and `ProductPage` models, including defensive JSON defaults.
- `lib/service/dummyJson_api.dart` — HTTP requests, endpoint construction, timeout handling, JSON decoding, and readable API errors.
- `lib/repository/product_repository.dart` — data-access boundary used by presentation code.
- `lib/viewmodel/catalog_viewmodel.dart` — list state, pagination, search, refresh, retry, and stale-request protection.
- `lib/view/catalog_page.dart` — responsive catalog UI and user interactions.
- `lib/view/product_detail_page.dart` — detail loading, retry UI, and the image gallery.

The UI does not call HTTP directly. Keeping network work in the service and repository means widgets only render state and handle interactions. The ViewModel tracks a request version so an older, slower search response cannot replace the results of a newer query.

## Testing

`test/widget_test.dart` verifies `ProductPage` parsing, including safe defaults for optional API fields.

## Trade-offs and future improvements

This was deliberately scoped as a small assessment project. Given more time, I would add:

- Product navigation by category so users can find items quickly
- Dependency injection and feature-level state management as the app grows
- Role-based access control for catalog managements
- More API-service and controller tests, including pagination and error scenarios

## AI assistance disclosure

AI assistance was used for:
- README documentations
- Implementation guidance
- UI iteration
- Code review
