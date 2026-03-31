import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/shop_provider.dart';
import '../models/product.dart';
import 'product_detail.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(builder: (ctx, shop, _) {
      if (shop.loading && shop.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // pick some randomized hot products to display as ads
      final ads = shop.hotProducts(count: 10).toList();
      ads.shuffle();
      final top3 = ads.take(3).toList();

      Widget adCard(BuildContext ctx, int index) {
        final p = top3[index];
        return _AdCard(product: p);
      }

      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text('Featured', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: top3.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: adCard,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Explore our Shop for more items', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            // teaser list
            Expanded(
              child: ListView.builder(
                itemCount: shop.products.length,
                itemBuilder: (context, i) {
                  final p = shop.products[i];
                  return ListTile(
                    title: Text(p.title),
                    subtitle: Text('${p.category} • \$${p.price.toStringAsFixed(2)}'),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetail(productId: p.id))),
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }
}

class _AdCard extends StatefulWidget {
  final Product product;
  const _AdCard({Key? key, required this.product}) : super(key: key);

  @override
  State<_AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<_AdCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _scale = 1.03),
      onExit: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 180),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetail(productId: widget.product.id))),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (c, u, e) => const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        const Text('Discover the timeless elegance of this product — crafted for everyday moments.', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text('\$${widget.product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
