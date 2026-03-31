import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import 'home_page.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final List<Widget> _pages = const [HomePage(), ShopPage(), CartPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    // fetch products once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = Provider.of<ShopProvider>(context, listen: false);
      shop.fetchProducts();
    });
  }

  void _setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P-BUY')),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BottomNav(selectedIndex: _index, onTap: _setIndex),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  Widget _item(BuildContext context, int idx, IconData icon, String label) {
    final active = idx == selectedIndex;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTap(idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: active ? Colors.grey.withOpacity(0.08) : Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(scale: active ? 1.15 : 1.0, duration: const Duration(milliseconds: 180), child: Icon(icon, color: active ? Theme.of(context).primaryColor : Colors.black54)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 12, color: active ? Theme.of(context).primaryColor : Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15)))),
        child: Row(
          children: [
            _item(context, 0, Icons.home_outlined, 'Home'),
            _item(context, 1, Icons.storefront_outlined, 'Shop'),
            _item(context, 2, Icons.receipt_long_outlined, 'My Order'),
            _item(context, 3, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }
}
