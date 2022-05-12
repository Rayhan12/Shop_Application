import 'dart:convert';

import 'package:flutter/material.dart';
import '../Models/Product.dart';
import 'package:http/http.dart' as http;
class Products with ChangeNotifier
{
  List<Product> _items = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //     'https://images.unsplash.com/photo-1551721434-f5a13c7a6d14?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=700&q=80',
  //   ),
  //   Product(
  //       id: 'p2',
  //       title: 'Trousers',
  //       description: 'A nice pair of trousers.',
  //       price: 59.99,
  //       imageUrl:
  //       'https://images.unsplash.com/photo-1614630536429-74e43f302c31?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80'),
  //
  //   Product(
  //     id: 'p3',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //     'https://images.unsplash.com/photo-1612831660648-ba96d72bfc5b?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=925&q=80',
  //   ),
  //   Product(
  //       id: 'p4',
  //       title: 'Trousers',
  //       description: 'A nice pair of trousers.',
  //       price: 59.99,
  //       imageUrl:
  //       'https://images.unsplash.com/photo-1550529791-9799c4abb4ad?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=700&q=80')
  ];

  final String authToken;
  final String userId;
  Products(this.authToken , this._items , this.userId);

  List<Product> get items
  {
    return [..._items];
  }
  List<Product> get FevItems
  {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product searchById(String id)
  {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> getAndSetProduct([bool filter = false]) async
  {
    final filterData = filter? 'orderBy="userId"&equalTo="$userId"':"";
    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterData');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String , dynamic>;
      final List<Product> fachedProducts = [];

       url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$authToken');
      final userfev = await http.get(url);
      final data = json.decode(userfev.body) as Map <String , dynamic>;

      if(extractedData==null) return;
      extractedData.forEach((key, value) {
        var favVal = false;
         if(data!=null)
          {
            data.forEach((nkey, value) {
              if(key==nkey)
                {
                  favVal = value;
                }
            });
          }

        fachedProducts.insert(0,Product(
          id: key,
          title: value['title'],
          price: value['price'],
          description: value['description'],
          imageUrl: value['imageUrl'],
          isFavorite: data == null? false : favVal,
        ));
      });

      _items = fachedProducts;
      notifyListeners();
    }
    catch(error)
    {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async
  {
    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url, body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'userId' : userId,
      })
      );
      _items.insert(0, Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl
      ));
      notifyListeners();
    }
    catch (error)
    {
      throw error;
    }
  }
  Future<void> deleteProduct(String id) async
  {
    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final index = _items.indexWhere((element) => element.id == id);
    var product = _items[index];
    await http.delete(url).then((_) => {
        product = null
    }).catchError((error){
      _items.insert(index, product);
      notifyListeners();
  });
    _items.removeWhere((element) => element.id == id);
    notifyListeners();

  }



  Future<void> updateProduct(String id , Product newProduct) async
  {
    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    try {
      final response = await http.patch(url, body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }
      ));

      int index = _items.indexWhere((element) => element.id == id);
      if (index >= 0) {
        _items[index] = newProduct;
        notifyListeners();
      }
      else
        return;
    }
    catch(error)
    {
      throw error;
    }
  }
}