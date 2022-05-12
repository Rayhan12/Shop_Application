import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Models/Product.dart';
import 'package:shop_application/Provider/Cart.dart';
import 'package:shop_application/Provider/Products.dart';
import 'package:shop_application/Provider/auth.dart';
import 'package:shop_application/UI/CartScreen.dart';
import 'package:shop_application/Wdigets/Drawar.dart';
import 'package:shop_application/Wdigets/badge.dart';

class ProductDetail extends StatefulWidget {
  static const routeName = 'ProductDetail';

  // final Product product;
  // ProductDetail({@required this.product});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<Products>(context).searchById(productId);
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
          actions: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Consumer<Cart>(
                builder:(context , cart , child)=> Badge(
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart, size: 30,),
                    onPressed: ()
                    {
                      Navigator.popAndPushNamed(context, CartScreen.routName);
                    },
                  ),
                  value: cart.cartItemCount.toString(),
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    height: size.height * .3,
                    width: size.width * .5,
                    child: ClayContainer(
                      depth: 20,
                      spread: 5,
                      color: Colors.white,
                      child: Hero(
                        tag: product.id,
                        child: Image(
                          fit: BoxFit.cover,
                          image: NetworkImage(product.imageUrl),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      height: size.height * .3,
                      width: size.width * .5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .7,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "\$${product.price}",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .7,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "One Day Delivery",
                            maxLines: 100,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black.withOpacity(.7),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .7,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Consumer<Auth>(builder: (context , auth,child) =>ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    product.changeFavorit(product.id , auth.token , auth.userId);
                                  });
                                },
                                child: Icon(product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline),
                              ),),
                              SizedBox(
                                width: 10,
                              ),
                              Consumer<Cart>(
                                builder: (context, cart, child) =>
                                    Stack(clipBehavior: Clip.none, children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      cart.addItem(product.id, product.price,
                                          product.title);
                                    },
                                    child: Icon(Icons.add_shopping_cart),
                                  ),
                                  if (cart.singleProductCount(product.id) > 0)
                                    Positioned(
                                      right: -10,
                                      top: -5,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        width: 25,
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                width: 2, color: Colors.white),
                                            color:
                                                Theme.of(context).primaryColor),
                                        child: FittedBox(
                                          child: Text(
                                            cart.singleProductCount(
                                                        product.id) >
                                                    0
                                                ? cart.items.values
                                                    .firstWhere((element) =>
                                                        element.id == productId)
                                                    .quantity
                                                    .toString()
                                                : 0.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: size.width,
                  // height: size.height * .15,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "Details: ${product.description}",
                          maxLines: 100,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withOpacity(.7),
                            fontSize: 17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
