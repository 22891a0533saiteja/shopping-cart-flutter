import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import 'cart_page.dart';
import 'explore_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final currentIndex = ref.watch(navigationProvider);

        final List<Widget> _pages = [
          const ExplorePage(),
          const CartPage(),
          const Center(child: Text('Shop Page')),
          const Center(child: Text('Account Page')),
        ];

        return Scaffold(
          body: _pages[currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(navigationProvider.notifier).state = index;
            },
            backgroundColor:
                Colors.blue, // Background color of the navigation bar
            selectedItemColor: Colors.black, // Color of the selected item
            unselectedItemColor: Colors.grey, // Color of the unselected items
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}
