import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_application/Models/Product.dart';
import 'package:shop_application/Provider/Cart.dart';
import 'package:http/http.dart' as http;

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final date;

  Order({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.date,
  });
}

class OrderItem with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  final String authToken;
  final String userId;
  OrderItem(this.authToken , this.userId ,this._orders);

  Future<void> getAndSetOrders() async {
    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Order> tempOrders = [];
      if (extractedData == null) return Future.value();
      extractedData.forEach((key, value) {
        tempOrders.add(Order(
          id: key,
          amount: value['amount'],
          date: DateTime.parse(value['date']),
          products: (value['products'] as List<dynamic>)
              .map((element) =>
              CartItem(
                  id: element['id'],
                  price: double.parse(element['price'].toString()),
                  title: element['title'],
                  quantity: element['quantity']),
          )
              .toList(),
        ));
      });
      _orders = tempOrders.reversed.toList();
      notifyListeners();
    }
    catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> carts, double total) async {
    final timeStamp = DateTime.now();
    var url = Uri.parse(
        'https://shop-3da59-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': carts.map((element) =>
            {
              'id': element.id,
              'title': element.title,
              'price': element.price,
              'quantity': element.quantity
            })
                .toList(),
            'date': timeStamp.toIso8601String()
          }));
      //await userViewOfOrder(carts, total);
      _orders.add(
          Order(
            id: json.decode(response.body)['name'],
            date: timeStamp,
            amount: total,
            products: carts,
          ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }


  // Future<void> userViewOfOrder(List<CartItem> carts , double total ) async
  // {
  //   final time = DateTime.now();
  //   var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/ordersUserView/$userId.json?auth=$authToken');
  //   await http.post(url , body: json.encode({
  //     'amount' : total ,
  //     'products' : carts.map((ele) => {
  //       'id' : ele.id,
  //       'title': ele.title,
  //       'price': ele.price,
  //       'quantity' : ele.quantity
  //     } ).toList(),
  //      'date' : time.toIso8601String()
  //   }));
  // }

  Future<void> deleteOrder(String id) async {

    //var orderDataIndex = _orders.indexWhere((element) => element.id == id);
    var orderData = _orders.firstWhere((element) => element.id == id);
    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/orders/$userId/$id.json?auth=$authToken');
    await http.delete(url).then((_) => {
      orderData = null
    }).catchError((error){
      _orders.add(orderData);
      notifyListeners();
    });

    _orders.removeWhere((element) => element.id == id);
    notifyListeners();

  }
}
