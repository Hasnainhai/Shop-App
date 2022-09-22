// ignore_for_file: import_of_legacy_library_into_null_safe, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import './screens/splashScreen.dart';
import '../provider/auth.dart';
import '../screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './provider/products.dart';
import 'package:provider/provider.dart';
import './provider/card.dart';
import './provider/orders.dart';
import './screens/order_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ProxyProvider<Auth, Products>(
          update: (ctx, auth, prevProducts) => Products(
            auth.token.toString(),
            auth.userId.toString(),
            prevProducts == null ? [] : prevProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ProxyProvider<Auth, Order>(
          update: (ctx, auth, prevoiusOrder) => Order(
            auth.token.toString(),
            auth.userId.toString(),
            prevoiusOrder == null ? [] : prevoiusOrder.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Inter',
          ),
          home: auth.isAuth
              ? productOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            productDetailScreen.routeName: (ctx) => productDetailScreen(),
            cartScreen.routeName: (ctx) => cartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            userProductScreen.routeName: (ctx) => userProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
