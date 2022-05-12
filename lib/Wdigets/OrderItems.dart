import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Provider/Cart.dart';

class OrderItems extends StatelessWidget {
  final String id, title;
  final int quantity;
  final double price;

  OrderItems(
      {@required this.id,
      @required this.title,
      @required this.price,
      @required this.quantity});

  var f = NumberFormat('###.0#', "en_US");

  // void confirm(BuildContext context, bool state) {
  //   final cart = Provider.of<Cart>(context);
  //   if (state == true) cart.deleteItem(id);
  // }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      elevation: 3,
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actions: [
          IconSlideAction(
            color: Theme.of(context).accentColor,
            icon: Icons.delete,
            foregroundColor: Colors.white,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Delete Item from Cart"),
                        content: Text(
                            "Are you sure about removing this item from the cart?"),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              cart.deleteItem(id);
                              Navigator.of(context).pop();
                            },
                            child: Text("Yes" , style: TextStyle(color: Colors.white),),
                            color: Colors.redAccent,
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("No" , style: TextStyle(color: Colors.white),),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ));
            },
          ),
          IconSlideAction(
            color: Theme.of(context).primaryColor,
            icon: Icons.add,
            foregroundColor: Colors.white,
            onTap: () {
              cart.addItem(id, price, title);
            },
          ),
          IconSlideAction(
            color: Theme.of(context).accentColor,
            icon: Icons.remove,
            foregroundColor: Colors.white,
            onTap: () {
              cart.reduceItem(id);
            },
          ),
        ],
        actionExtentRatio: 1 / 5,
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: ListTile(
            title: Text(title),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "\$ $price",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            subtitle: Text("Total: \$${f.format(price * quantity)}"),
            isThreeLine: true,
            trailing: Text("$quantity x", style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
