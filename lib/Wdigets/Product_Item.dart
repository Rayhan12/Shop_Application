import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Models/Product.dart';
import 'package:shop_application/Provider/Cart.dart';
import 'package:shop_application/Provider/auth.dart';
import 'package:shop_application/UI/Product_Detiles_Screen.dart';
import 'package:shop_application/Wdigets/badge.dart';

class ProductItem extends StatefulWidget {
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final Color background = Color(0xFFfffde8);
    return ClayContainer(
      borderRadius: 10,
      //parentColor: background,
      spread: 5,
      depth: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: GridTile(
          header: Container(
            padding: EdgeInsets.symmetric(vertical: 2),
            color: Colors.black87,
            child: Text(
              product.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: .7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          child: InkWell(
            onTap: () {
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              //   return ProductDetail(
              //     product: widget.product,
              //   );
              // }));

              Navigator.of(context)
                  .pushNamed(ProductDetail.routeName, arguments: product.id);
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: AssetImage('Assets/Images/pp.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(
              "\$ ${product.price.toString()}",
              textAlign: TextAlign.center,
            ),
            //subtitle: Text(widget.product.description),
            leading: Consumer<Product>(
              builder: (context, product, child) => IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_outlined),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  product.changeFavorit(product.id, auth.token, auth.userId);
                },
              ),
            ),
            trailing: Badge(
              value: cart.singleProductCount(product.id).toString(),
              color: Colors.white,
              child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).accentColor,
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  setState(() {
                    cart.addItem(product.id, product.price, product.title);
                  });
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("${product.title} was added to your cart"),
                    duration: Duration(milliseconds: 2000),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        setState(() {
                          cart.reduceItem(product.id);
                        });
                      },
                    ),
                  ));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
