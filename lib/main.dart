import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shop_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/main_scaffold.dart';
import 'pages/cart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'P-BUY',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainScaffold(),
        routes: {
          '/cart': (_) => const CartPage(),
        },
      ),
    );
  }
}
