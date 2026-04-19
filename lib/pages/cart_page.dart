import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Consumer2<ShopProvider, AuthProvider>(builder: (ctx, shop, auth, _) {
        final items = shop.cart.entries.toList();
        double total = 0;
        for (var e in items) {
          final product = shop.products.firstWhere((p) => p.id == e.key);
          total += product.price * e.value;
        }

        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Keranjang kosong'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final entry = items[i];
                        final product = shop.products.firstWhere((p) => p.id == entry.key);
                        return ListTile(
                          leading: SizedBox(width: 56, height: 56, child: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover, placeholder: (c,u) => const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)), errorWidget: (c,u,e) => const Icon(Icons.broken_image))),
                          title: Text(product.title),
                          subtitle: Text('x${entry.value} • \$${(product.price * entry.value).toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () => shop.removeFromCart(product.id), icon: const Icon(Icons.remove)),
                              IconButton(onPressed: () => shop.addToCart(product.id), icon: const Icon(Icons.add)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(child: Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18))),
                  ElevatedButton(onPressed: shop.cart.isEmpty ? null : () { shop.clearCart(); }, child: const Text('Clear'))
                ],
              ),
            )
            ,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: ElevatedButton(
                onPressed: shop.cart.isEmpty
                    ? null
                    : auth.isAuthenticated
                    ? () {
                        // perform checkout (client-side): clear cart and show confirmation
                        shop.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order placed successfully')),
                        );
                      }
                    : () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                child: Text(auth.isAuthenticated ? 'Checkout' : 'Sign in to Checkout'),
              ),
            )
          ],
        );
      }),
    );
  }
}
