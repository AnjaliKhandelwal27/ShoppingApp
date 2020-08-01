import 'package:flutter/material.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class OrderItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem({
    @required this.dateTime,
    @required this.id,
    @required this.amount,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://shopping-app-571f9.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        dateTime: timestamp,
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://shopping-app-571f9.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
//    print(json.decode(response.body));
     List<OrderItem> loadedOrders = [];
    final extractedProduct = json.decode(response.body) as Map<String, dynamic>;
    if (extractedProduct == null) {
      return;
    }

    extractedProduct.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          dateTime: DateTime.parse(orderData['dateTime']),
          id: orderId,
          amount: orderData['amount'],

          products: (orderData['products'] as List<dynamic>)
              .map(

                (item) => CartItem(
                  id: item['id'],
                  quantity: item['quantity'],
                  price: item['price'],
                  title: item['title'],
                ),


          )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
