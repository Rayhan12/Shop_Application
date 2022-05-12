import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Provider/Cart.dart';
import 'package:shop_application/Provider/Products.dart';
import 'package:shop_application/UI/CartScreen.dart';
import 'package:shop_application/Wdigets/Drawar.dart';
import 'package:shop_application/Wdigets/badge.dart';

import '../Wdigets/Product_Item.dart';
import '../Models/Product.dart';

enum filter
{
  All,
  Favorite
}


class ProductOverViewScreen extends StatefulWidget {
  static const routeName = "ProductOverViewScreen";
  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {

  var showFav = false;
  bool isDone = true;
  bool loading = true;

  @override
  void didChangeDependencies() {
    if(isDone)
      {
        Provider.of<Products>(context).getAndSetProduct().then((value) => {
          loading = false
        });
        isDone = false;
      }
    super.didChangeDependencies();
  }

  Future<void> refreshPage(BuildContext cont) async
  {
    await Provider.of<Products>(cont).getAndSetProduct();
    
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final dummyData = showFav ? productsData.FevItems : productsData.items;
    final size = MediaQuery.of(context).size;
    int itemCount() {
      if (size.width > 800) {
        return 4;
      } else if (size.width > 500 && size.width < 799)
        return 3;
      else
        return 2;
    }



    return SafeArea(
      child: Scaffold(
          drawer: CustomDrawer(),
        extendBody: true,
        appBar: AppBar(
          title: Text("Shop-Chop"),
          actions: [
            Consumer<Cart>(
              builder: (_,cart,child) => Badge(
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_rounded),
                  onPressed: (){
                    Navigator.of(context).pushNamed(CartScreen.routName);
                  },
                ),
                value: cart.cartItemCount.toString(),
                color: Colors.black54,

              ),
            ),

            PopupMenuButton(
              onSelected: (selected)
              {
                setState(() {
                  if(selected == filter.Favorite)
                  {
                    showFav =true;
                  }
                  else
                  {
                    showFav = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: filter.All,
                  child: Row(
                    children: [
                      Text("Show All"),
                      SizedBox(width: 10,),
                      Icon(Icons.category, color: Theme.of(context).accentColor,)
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: filter.Favorite,
                  child: Row(
                    children: [
                      Text("Favorite"),
                      SizedBox(width: 10,),
                      Icon(Icons.favorite, color: Theme.of(context).accentColor,)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body:loading? Center(child: CircularProgressIndicator()): Scrollbar(
          isAlwaysShown: true,
          child: RefreshIndicator(
            onRefresh: () {
              setState(() {
                productsData.getAndSetProduct();
              });
              return Future.value();
            },
            child: GridView.builder(
              itemCount: dummyData.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                return ChangeNotifierProvider.value(
                  value: dummyData[index],
                  child: ProductItem(
                      // product: dummyData[index],
                      ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: itemCount(),
                childAspectRatio: .9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
