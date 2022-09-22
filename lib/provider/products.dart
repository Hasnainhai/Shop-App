// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:shop_app/provider/product.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'P1',
    //   title: 'Pents',
    //   describtion:
    //       'I was standing on the corner with my friends and we saw some girls we knew from school,',
    //   price: 99.99,
    //   imageUrl:
    //       'https://thumbs.dreamstime.com/z/gray-sports-pants-gray-sports-pants-boy-isolated-white-background-104351232.jpg',
    // ),

    // Product(
    //   id: 'P3',
    //   title: 'Shirt',
    //   description: 'This is a sports shoes which brand is CR-7',
    //   price: 104.0,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Shirt.jpg/640px-Shirt.jpg',
    // ),
    //  Product(
    //   id: 'P2',
    //   title: 'Watch',
    //   description: 'A new pents! which is only for Medium',
    //   price: 66.90,
    //   imageUrl: 'https://thumbs.dreamstime.com/b/gold-watch-13362757.jpg',
    // ),
    // Product(
    //   id: 'P4',
    //   title: 'Shoes',
    //   description: 'this is a branded Watch which name is rollex',
    //   price: 99.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Sports_shoes.jpg/640px-Sports_shoes.jpg',
    // ),
  ];
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String? id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shop-app-73466-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }

      url =
          'https://shop-app-73466-default-rtdb.firebaseio.com/userFavourite/$userId.json?auth=$authToken';
      final FavouriteResponse = await http.get(url);
      final FavouriteData = json.decode(FavouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            describtion: prodData['describtion'],
            price: prodData['price'],
            isFavourite: FavouriteData == null ? false : FavouriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
            
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      // print(error);
      // throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
     final url = 'https://shop-app-73466-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'describtion': product.describtion,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId' : userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        describtion: product.describtion,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodtIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodtIndex >= 0) {
      final url =
          'https://shop-app-73466-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'describtion': newProduct.describtion,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodtIndex] = newProduct;
      notifyListeners();
    } else {
      print('.....');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-app-73466-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete Product From the File.');
    }
    existingProduct = null;
  }
}
