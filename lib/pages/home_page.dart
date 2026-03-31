import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/shop_provider.dart';
import '../models/product.dart';
import 'product_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _initiated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initiated) {
      _initiated = true;
      final shop = Provider.of<ShopProvider>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        shop.fetchProducts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Shop'),
        actions: [
          Consumer<ShopProvider>(builder: (ctx, shop, _) {
            final count = shop.cart.values.fold<int>(0, (a, b) => a + b);
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    )
                ],
              ),
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
            );
          })
        ],
      ),
      body: Consumer<ShopProvider>(builder: (ctx, shop, _) {
        if (shop.loading && shop.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final selected = shop.selectedCategory;
        final categories = shop.categories;

        Widget topSection() {
          final hot = shop.hotProducts();
          return SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hot.length,
                itemBuilder: (context, i) {
                final p = hot[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetail(productId: p.id))),
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: p.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        Widget productList(List<Product> list) {
          return Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                return ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(p.title),
                  subtitle: Text('${p.category} • \$${p.price.toStringAsFixed(2)}'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetail(productId: p.id))),
                );
              },
            ),
          );
        }

        return Column(
          children: [
            // Filters
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('All'),
                    selected: selected == null,
                    onSelected: (_) => shop.setCategory(null),
                  ),
                  const SizedBox(width: 8),
                  for (var cat in categories) ...[
                    ChoiceChip(
                      label: Text(cat),
                      selected: selected == cat,
                      onSelected: (_) => shop.setCategory(selected == cat ? null : cat),
                    ),
                    const SizedBox(width: 8),
                  ]
                ],
              ),
            ),
            // Content
            if (selected == null) ...[
              topSection(),
              const Divider(),
              Expanded(child: productList(shop.products)),
            ] else ...[
              // merged view when a filter is selected
              Expanded(child: productList(shop.productsByCategory(selected))),
            ]
          ],
        );
      }),
    );
  }
}
