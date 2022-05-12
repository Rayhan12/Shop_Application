import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  int quantity;

  CartItem(
      {@required this.id, @required this.title, @required this.price, @required this.quantity});
}


class Cart with ChangeNotifier
{
  Map<String,CartItem> _items = {};

  Map<String , CartItem> get items
  {
    return {..._items};
  }

  int get cartItemCount
  {
    return _items==null ? 0 : _items.length;
  }

  double get totalAmount
  {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price*value.quantity;
    });
    return total;
  }

  void addItem(String ProductID , double price , String title )
  {
      if(_items.containsKey(ProductID))
        {
          _items.update(ProductID, (value) => CartItem(
            id: value.id,
            quantity: value.quantity+1,
            price: value.price,
            title: value.title
          ));
        }
      else
        {
          _items.putIfAbsent(ProductID, () => CartItem(
            title: title,
            id: ProductID,
            price: price,
            quantity: 1
          ));
        }
      notifyListeners();
  }

  int singleProductCount(String productID)
  {
    if(_items.containsKey(productID))
      {
        return _items.values.firstWhere((element) => element.id==productID).quantity;
      }
    else return 0;

  }

  void reduceItem(String productID)
  {
      // ignore: unrelated_type_equality_checks
      if(_items.values.firstWhere((element) => element.id==productID).quantity == 1)
        {
          deleteItem(productID);
        }
      else
        {
          _items.values.forEach((element) {
            if (element.id == productID) {
                element.quantity -= 1;
            }
          });
        }
      notifyListeners();
  }
  void deleteItem(String productID)
  {
    _items.removeWhere((key, value) => value.id==productID);
    notifyListeners();
  }

  void clear()
  {
    _items = {};
    notifyListeners();
  }
}
