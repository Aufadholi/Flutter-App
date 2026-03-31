import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/shop_provider.dart';

class ProductDetail extends StatelessWidget {
  final String productId;
  const ProductDetail({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context, listen: false);
    final product = shop.products.firstWhere((p) => p.id == productId);

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 240, child: Center(child: CachedNetworkImage(imageUrl: product.imageUrl, placeholder: (c,u) => const CircularProgressIndicator(), errorWidget: (c,u,e) => const Icon(Icons.broken_image)))),
            const SizedBox(height: 12),
            Text(product.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 12),
            Text(product.description),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      shop.addToCart(product.id);
                      Navigator.of(context).pushNamed('/cart');
                    },
                    child: const Text('Add to Cart & Checkout'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
