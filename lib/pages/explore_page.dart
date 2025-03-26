import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  late Future<List<Product>> _futureProducts;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProducts();
  }

  // Fetch products from the API
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products'));

      if (response.statusCode == 200) {
        // Log the response body for debugging
        print('API Response: ${response.body}');

        final Map<String, dynamic> parsedJson = json.decode(response.body);
        final List<dynamic> productList = parsedJson['products'];
        return productList.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Filter products based on search query
  List<Product> _filterProducts(List<Product> products, String query) {
    if (query.isEmpty) {
      return products; // Return all products if the query is empty
    }
    return products.where((product) {
      final title = product.title?.toLowerCase() ?? '';
      final category = product.category?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase()) || category.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by title or category',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query; // Update the search query
                });
              },
            ),
          ),
          // Product Grid
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _futureProducts, // Fetch products from the API
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while fetching data
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Show an error message if something went wrong
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Show a message if no data is available
                  return const Center(child: Text('No products found'));
                } else {
                  // Filter products based on the search query
                  final products = _filterProducts(snapshot.data!, _searchQuery);

                  if (products.isEmpty) {
                    return const Center(child: Text('No matching products found'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Consumer(
                        builder: (context, ref, _) {
                          return ProductCard(
                            product: product,
                            onAddToCart: () {
                              ref.read(cartProvider.notifier).addToCart(product);
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the text controller
    super.dispose();
  }
}