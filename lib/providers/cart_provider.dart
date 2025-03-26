import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<Product, int>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<Product, int>> {
  CartNotifier() : super({});

  // Add or increment the quantity of a product in the cart
  void addToCart(Product product) {
    state = {
      ...state,
      product:
          (state[product] ?? 0) + 1, // Increment quantity if product exists
    };
  }

  // Remove a product from the cart
  void removeFromCart(Product product) {
    if (state.containsKey(product)) {
      final newCart = Map<Product, int>.from(state);
      newCart.remove(product);
      state = newCart;
    }
  }

  // Update the quantity of a product in the cart
  void updateQuantity(Product product, int delta) {
    if (state.containsKey(product)) {
      final currentQuantity = state[product]!;
      if (delta == -1 && currentQuantity > 1) {
        state = {...state, product: currentQuantity - 1};
      } else if (delta == 1) {
        state = {...state, product: currentQuantity + 1};
      }
    }
  }

  // Calculate the total price of all items in the cart
  double calculateTotal() {
    double total = 0;
    state.forEach((product, quantity) {
      final price = product.price ?? 0.0; // Use 0.0 if price is null
      total += price * quantity;
    });
    return total;
  }
}
