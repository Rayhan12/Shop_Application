import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Provider/Cart.dart';
import 'package:shop_application/Provider/Order.dart';
import 'package:shop_application/Provider/Products.dart';
import 'package:shop_application/Provider/auth.dart';
import 'package:shop_application/UI/CartScreen.dart';
import 'package:shop_application/UI/EditProductScreen.dart';
import 'package:shop_application/UI/OrderScreen.dart';
import 'package:shop_application/UI/SplashScreen.dart';
import 'package:shop_application/UI/YourProductScreen.dart';
import 'package:shop_application/UI/auth_screen.dart';
import 'package:shop_application/Wdigets/OrderItems.dart';
import './UI/HomePage.dart';
import 'UI/Product_Detiles_Screen.dart';
import 'UI/Product_OverView_Screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Color background = Color(0xFFfcfbf0);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              update: (context, auth, oldProduct) => Products(
                  auth.token, oldProduct == null ? [] : oldProduct.items , auth.userId)
          ),
          ChangeNotifierProvider(create: (context) => Cart()),
          ChangeNotifierProxyProvider<Auth, OrderItem>(
              update: (context, auth, oldOrders) => OrderItem(
                  auth.token, auth.userId ,oldOrders == null ? [] : oldOrders.orders)
          )
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              //scaffoldBackgroundColor: background,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth ? ProductOverViewScreen() :FutureBuilder(
                future: auth.autoLogin(),
                builder: (context , snapshot) => snapshot.connectionState == ConnectionState.waiting? SplashScreen() : AuthScreen()) ,
            routes: {
              ProductOverViewScreen.routeName: (context) =>
                  ProductOverViewScreen(),
              ProductDetail.routeName: (context) => ProductDetail(),
              CartScreen.routName: (context) => CartScreen(),
              OrderScreen.routeName: (context) => OrderScreen(),
              YourProductScreen.routeName: (context) => YourProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
