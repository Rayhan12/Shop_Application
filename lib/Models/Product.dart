import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.imageUrl,
      @required this.price,
      this.isFavorite = false});

  Future<void> changeFavorit(String id , String authToken ,String userID) async {
    if (isFavorite == false)
      isFavorite = true;
    else
      isFavorite = false;

    var url = Uri.parse('https://shop-3da59-default-rtdb.firebaseio.com/userFav/$userID/$id.json?auth=$authToken');
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if(response.statusCode>= 400)
        {
          isFavorite = !isFavorite;
          notifyListeners();
        }
    }
      catch(error)
    {
      isFavorite = !isFavorite;
      notifyListeners();
    }

    notifyListeners();
  }
}
