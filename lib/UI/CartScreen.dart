import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Provider/Cart.dart';
import 'package:shop_application/Provider/Order.dart';
import 'package:shop_application/Wdigets/Drawar.dart';
import 'package:shop_application/Wdigets/OrderItems.dart';

class CartScreen extends StatefulWidget {
  static const routName = "CartScreen";

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var f = NumberFormat('###.0#', 'en_US');
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final orders = Provider.of<OrderItem>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your Cart"),
        ),
        drawer: CustomDrawer(),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.menu , color: Colors.white,),
        //   elevation: 4,
        //   onPressed: ()
        //   {
        //     setState(() {
        //       Scaffold.of(context).openDrawer();
        //     });
        //   },
        // ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 3,
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total:",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    //Spacer(),
                    Chip(
                      label: Text(
                        "\$ ${f.format(cart.totalAmount)}",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width*.1,
                    // ),
                    OrderButton(cart: cart, orders: orders)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: cart.cartItemCount,
                  itemBuilder: (context, index) {
                    return OrderItems(
                      id: cart.items.values.toList()[index].id,
                      title: cart.items.values.toList()[index].title,
                      price: cart.items.values.toList()[index].price,
                      quantity: cart.items.values.toList()[index].quantity.toInt(),
                    );
                  },
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
    @required this.orders,
  }) : super(key: key);

  final Cart cart;
  final OrderItem orders;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:(widget.cart.totalAmount<= 0 || loading)? null : () async {
        setState(() {
          loading = true;
        });
       await widget.orders.addOrder(widget.cart.items.values.toList(), widget.cart.totalAmount);

        setState(() {
          loading = false;
          showDialog(context: context, builder: (context)=> AlertDialog(
            title: Text("Success!!"),
            content: Text("Your Order Was Placed!!"),
            actions: [
              ElevatedButton(onPressed:() =>{Navigator.of(context).pop()}, child:Text("Close"))
            ],
          ));
        });
       widget.cart.clear();
      },
      child: loading? CircularProgressIndicator() : Text(
        "Order Now",
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 17),
      ),
    );
  }
}
