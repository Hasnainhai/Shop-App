import 'package:flutter/material.dart';
import 'package:shop_app/provider/products.dart';
import './product_item.dart';
import 'package:provider/provider.dart';

class productsGrid extends StatelessWidget {
  final bool showFav;
  productsGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFav ? productsData.favouriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: productItems(),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        mainAxisExtent: 150,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
      ),
    );
  }
}
