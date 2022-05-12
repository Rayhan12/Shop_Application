import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Models/Product.dart';
import 'package:shop_application/Provider/Products.dart';
import 'package:shop_application/UI/EditProductScreen.dart';
import 'package:shop_application/Wdigets/Drawar.dart';

class YourProductScreen extends StatefulWidget {
  static const routeName = "YourProductScreen";

  @override
  _YourProductScreenState createState() => _YourProductScreenState();
}

class _YourProductScreenState extends State<YourProductScreen> {

  Future<void> _refreshPage(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).getAndSetProduct(true);
  }

  @override
  void initState() {
    _refreshPage(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   // final products = Provider.of<Products>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Product Manager"),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
            ),
          ],
        ),
        drawer: CustomDrawer(),
        body: FutureBuilder(
          future: _refreshPage(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      // products.getAndSetProduct(true);
                      _refreshPage(context);
                    });
                    return Future.value();
                  },
                  child: Consumer<Products>(
                    builder: (context , products , child) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        itemCount: products.items.length,
                        itemBuilder: (context, index) {
                          return EditableProducts(product: products.items[index]);
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class EditableProducts extends StatefulWidget {
  final Product product;

  EditableProducts({@required this.product});

  @override
  _EditableProductsState createState() => _EditableProductsState();
}

class _EditableProductsState extends State<EditableProducts> {
  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ListTile(
            leading: Container(
              height: 70,
              width: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(.2),
                        spreadRadius: 3,
                        blurRadius: 1)
                  ]),
              clipBehavior: Clip.hardEdge,
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(widget.product.imageUrl),
              ),
            ),
            title: Text(
              widget.product.title,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text("\$${widget.product.price}"),
            trailing: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          EditProductScreen.routeName,
                          arguments: widget.product);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      products.deleteProduct(widget.product.id);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
