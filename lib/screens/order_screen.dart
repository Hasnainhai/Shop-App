import 'package:flutter/material.dart';
import '../widgets/app_drewer.dart';
import '../provider/orders.dart' show Order;
import 'package:provider/provider.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future? _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Order>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  // var _isloading = false;

  // @override
  // void initState() {
  //   // Future.delayed(Duration.zero).then((_) async {
  //     _isloading = true;
  //   Provider.of<Order>(context, listen: false).fetchAndSetOrders().then((_) {
  //      setState(() {
  //     _isloading = false;
  //   });
  //   });

  //   // });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
      ),
      drawer: const appDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } 
          // else {
          //   if (dataSnapshot != null) {
          //     return Center(
          //       child: Text('An error can be occured!'),
          //     );
          //   }
             else {
              return Consumer<Order>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                ),
              );
            }
          // }
        },
      ),
    );
  }
}
