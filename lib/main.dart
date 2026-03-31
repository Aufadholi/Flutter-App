import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shop_provider.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ShopProvider())],
      child: MaterialApp(
        title: 'Online Shop',
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: {
          '/': (_) => const HomePage(),
          '/cart': (_) => const CartPage(),
        },
      ),
    );
  }
}
