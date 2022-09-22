// ignore_for_file: deprecated_member_use, non_constant_identifier_names, camel_case_types, sort_child_properties_last,
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/card.dart';
import '../widgets/app_drewer.dart';
import '../screens/cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../provider/products.dart';

enum FilterOption {
  Favourite,
  all,
}

class productOverViewScreen extends StatefulWidget {
  @override
  State<productOverViewScreen> createState() => _productOverViewScreenState();
}

class _productOverViewScreenState extends State<productOverViewScreen> {
  var _ShowOnlyFavourite = false;
  var _isInIt = true;
  var _isloading = false;
  @override
  void initState() {
    // Future.delayed(Duration.zero).then((_) => {
    //  Provider.of<Products>(context).fetchAndSetProducts(),
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isloading = true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isloading = false;
        });
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption SelectedValue) {
              setState(() {
                if (SelectedValue == FilterOption.Favourite) {
                  _ShowOnlyFavourite = true;
                } else {
                  _ShowOnlyFavourite = false;
                  
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text(
                  'Only Favourite',
                ),
                value: FilterOption.Favourite,
              ),
              const PopupMenuItem(
                child: Text(
                  'All',
                ),
                value: FilterOption.all,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, CartData, ch) => Badge(
              value: CartData.itemCount.toString(),
              colour: Theme.of(context).accentColor,
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(cartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const appDrawer(),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : productsGrid(_ShowOnlyFavourite),
    );
  }
}
