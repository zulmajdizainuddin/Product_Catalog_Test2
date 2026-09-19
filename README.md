# Product Catalog

This is a small Flutter app I built for the Neurogine Junior Mobile Developer assessment. It shows a list of products from the free DummyJSON API, with pagination, search, and a detail screen. It also handles the loading, error, empty, and success states so the app always shows something sensible.

## Stack

- Flutter 3.24.4 (stable)
- Dart 3.5.4
- provider for state management
- http for network calls
- cached_network_image for images

## How to run

You need the Flutter SDK (3.24.4 or close to it) and an emulator or a real device. I tested it on the Android Pixel 5 emulator.

```bash
# 1. Clone the repo
git clone https://github.com/zulmajdizainuddin/Product_Catalog_Test2.git
cd Product_Catalog_Test2

# 2. Get the packages
flutter pub get

# 3. Run it (make sure an emulator or device is running)
flutter run
```

To run the tests:

```bash
flutter test
```

## Features

Required:

1. Product list with thumbnail, title, and price.
2. Pagination that loads more items as you scroll, using the API's skip value.
3. A detail screen with the product's images, price, rating, and description.
4. Loading, error (with a Retry button), empty, and success states, each shown differently.
5. A search box that is debounced.
6. Code split into a data layer and a ui layer.

Bonus (done):

- Pull to refresh on the list.
- Image placeholders while loading and a fallback icon if an image fails. The package also caches images.
- A unit test for the JSON parsing.

## How the code is organized

Everything sits under lib/ in two layers:

```
lib/
├── main.dart                       # starts the app, wires things together, sets the theme
├── data/                           # data layer: gets and shapes the data
│   ├── models/
│   │   └── product.dart            # the Product class and its JSON parsing
│   ├── services/
│   │   └── product_api_service.dart  # the actual HTTP calls
│   └── repositories/
│       └── product_repository.dart   # the one place the ui asks for data
└── ui/                             # ui layer: screens and state
    ├── providers/
    │   └── product_provider.dart   # holds the state (loading, data, error)
    └── screens/
        ├── product_list_screen.dart
        └── product_detail_screen.dart
```

The data flows like this: UI to Provider to Repository to Service to API.

The screens never call the API directly. A screen reads from the provider, the provider asks the repository, and only the service knows about HTTP and JSON. So each part has one job and I can change one without breaking the others.

In main.dart I create the service, pass it into the repository, then pass the repository into the provider. Nothing builds its own dependencies. That keeps things loosely connected and means I could pass a fake repository in a test.

For state I use one enum called ViewState with four values: loading, error, empty, success. The screen can only be in one of them at a time, and the list screen just switches on it to show the right thing.

This follows the basic idea behind Clean Architecture and SOLID: each file does one thing, and the dependencies are passed in instead of hard-coded.

## Decisions I made

State management: I went with Provider. For an app this small it is simple and easy to read, and I can explain all of it. Something bigger like Bloc felt like too much for the size of this task.

Search: I used the API's search endpoint instead of filtering on the phone. If I filtered locally I would only be searching the products already loaded, not the whole catalog. I also debounced it by 500ms so it only searches after you stop typing, instead of firing on every letter.

Detail screen: the list response already gives back the full product (description, rating, images), so I just pass the tapped product straight to the detail screen. There is no need to call the /products/{id} endpoint again and waste a request. If the list ever returned less data, I would switch to that endpoint.

Pagination: skip goes up by the page size after each load. I check if there is more by looking at whether a full page came back. If fewer than 20 come back, I know it is the end. There is also a guard so it does not load the next page twice at once.

Errors: the service throws if the response is not 200, and the provider catches it and shows the error state with a Retry button. If a later page fails while scrolling, I keep the products already on screen instead of clearing everything.

## Tests

test/product_test.dart tests Product.fromJson:

- Turning a normal, complete JSON object into a Product.
- An edge case: a product with no images field and a whole number price, to check the null handling (?? []) and the toDouble() both work.

I picked JSON parsing to test because it is the base of everything. If parsing is wrong, every screen shows wrong data. It is also pure logic with no UI or network, so it is quick and reliable to test.

## UI and UX bits I like

- The list uses cards with rounded images and a ripple when you tap. Long titles cut off after two lines so nothing overflows.
- One coral seed color sets the whole color scheme through Material 3, set once in main.dart, so both screens match.
- On the detail screen the price and rating are small rounded chips.
- The empty and error states have icons, not just plain text.

## AI usage

I used an AI assistant as a coding aid and learning tool, the same way I would use documentation or Stack Overflow. I used it to explain Flutter concepts, compare options (for example Provider vs Bloc, and server side vs client side search), review code, and help me to support during debug phase. I stayed in control of it. I reviewed and questioned things before using them, changed what I did not agree with, and made the architecture and design decisions myself.

## TODOs / things I did not finish

- Dark mode: I use theme colors instead of fixed ones, but I have not fully tested it in dark mode.
- loadProducts does not guard against being called twice quickly (loadMore does). Spamming Retry could overlap. Small issue for a demo, but I would fix it for a real app.
- More tests: only the JSON parsing is tested. Testing the provider and repository with a fake service would be a good next step.
- Data caching: images are cached but the product data is fetched fresh each time. A local cache would help offline.
- Search uses the full screen loading state. A smaller inline loader would feel nicer.