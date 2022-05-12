import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Provider/Order.dart';
import 'package:shop_application/Wdigets/Drawar.dart';
import 'package:shop_application/Wdigets/OrderItems.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = "OrderScreen";

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool loading = false;

  @override
  void initState() {
    loading = true;
    Provider.of<OrderItem>(context, listen: false)
        .getAndSetOrders()
        .then((value) => {
              setState(() {
                loading = false;
              })
            });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderItem>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your Orders History"),
        ),
        drawer: CustomDrawer(),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : orders.orders.length == 0
                ? Center(
                    child: Text(
                    "You don't have any order history yet..",
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ))
                : ListView.builder(
                    itemCount: orders.orders.length,
                    itemBuilder: (context, index) {
                      return DataContainer(order: orders.orders[index]);
                    },
                  ),
      ),
    );
  }
}

class DataContainer extends StatefulWidget {
  final Order order;

  DataContainer({@required this.order});

  @override
  _DataContainerState createState() => _DataContainerState();
}

class _DataContainerState extends State<DataContainer> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  var f = NumberFormat('###.0#', 'en_US');

  AnimationController _controller;
  Animation<double> _opacityAnimation;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(vsync:  this,duration: Duration(milliseconds: 400));
    _opacityAnimation = Tween(begin: 0.0 , end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _offsetAnimation = Tween<Offset>(begin: Offset(0.0,-0.3) , end:Offset(0,0)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderItem>(context);
    return Column(
      children: [
        Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Dismissible(
            key: ValueKey(widget.order.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
              return showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete from History"),
                  content: Text(
                    "Are you sure you want to delete this from the history?",
                    maxLines: 20,
                    overflow: TextOverflow.ellipsis,
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      color: Colors.redAccent,
                      child: Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        "No",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              orders.deleteOrder(widget.order.id);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 40),
              child: Icon(
                Icons.delete,
                color: _expanded ? Colors.redAccent : Colors.white,
              ),
              color: _expanded ? Colors.white : Colors.redAccent,
              //margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
            child: ListTile(
              tileColor:
                  _expanded ? Theme.of(context).accentColor : Colors.white,
              leading: Chip(
                label: FittedBox(
                  child: Text(
                    "\$${f.format(widget.order.amount)}",
                    style: TextStyle(
                        color: _expanded
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        fontSize: 18),
                  ),
                ),
                backgroundColor:
                    _expanded ? Colors.white : Theme.of(context).primaryColor,
              ),
              title: Text(
                "Order Details",
                style:
                    TextStyle(color: _expanded ? Colors.white : Colors.black87),
              ),
              subtitle: Text(
                DateFormat.yMMMMd().format(widget.order.date),
                style:
                    TextStyle(color: _expanded ? Colors.white : Colors.black87),
              ),
              trailing: IconButton(
                icon: Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: _expanded ? Colors.white : Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                    if(_expanded)
                      {
                        _controller.forward();
                      }
                    else
                      {
                        _controller.reverse();
                      }
                  });
                },
              ),
            ),
          ),
        ),
        if (_expanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            constraints: BoxConstraints(
              minHeight: _expanded ? (widget.order.products.length * 60.0 + 100.0) : 0,
              maxHeight: _expanded ? (widget.order.products.length * 60.0 + 100.0 + 200) : 0,
            ),
            height: min(widget.order.products.length * 60.0 + 100.0, 350.0),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                transformHitTests: false,
                position: _offsetAnimation,
                child: Card(
                  // color: Theme.of(context).accentColor,
                  elevation: 4,
                  child: ListView.builder(
                    itemCount: widget.order.products.length,
                    itemBuilder: (context, ind) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: OrderItems(
                          title: widget.order.products[ind].title,
                          id: widget.order.products[ind].id,
                          price: widget.order.products[ind].price,
                          quantity: widget.order.products[ind].quantity,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
