import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Provider/auth.dart';
import 'package:shop_application/UI/CartScreen.dart';
import 'package:shop_application/UI/OrderScreen.dart';
import 'package:shop_application/UI/Product_OverView_Screen.dart';
import 'package:shop_application/UI/YourProductScreen.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 4,
      child: Column(
        children: [
          AppBar(
            title: Text("Happy Shopping"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop , color: Theme.of(context).primaryColor,),
            title: Text("Shop"),
            onTap: ()
            {
              Navigator.pushReplacementNamed(context, ProductOverViewScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment , color: Theme.of(context).primaryColor,),
            title: Text("Order History"),
            onTap: ()
            {
              Navigator.pushReplacementNamed(context, OrderScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shopping_cart , color: Theme.of(context).primaryColor,),
            title: Text("Your Cart"),
            onTap: ()
            {
              Navigator.pushReplacementNamed(context, CartScreen.routName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category , color: Theme.of(context).primaryColor,),
            title: Text("Product Manager"),
            onTap: ()
            {
              Navigator.pushReplacementNamed(context, YourProductScreen.routeName);
            },
          ),
          Divider(),
          Consumer<Auth>(
            builder: (context , auth ,child) =>ListTile(
              leading: Icon(Icons.logout , color: Theme.of(context).primaryColor,),
              title: Text("LogOut"),
              onTap: ()
              {
                Navigator.of(context).pop();
                auth.logout();
              },
            ),
          )
        ],
      ),
    );
  }
}
