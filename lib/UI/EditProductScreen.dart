import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/Models/Product.dart';
import 'package:shop_application/Provider/Products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "EditProductScreen";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  ProductData productData =
      ProductData(title: "", price: null, description: "", imageUrl: "");
  var status = true;
  var liked = false;
  bool isDone = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(updateState);
    _imageUrlController.text = productData.imageUrl;
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(updateState);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (status &&
        ModalRoute.of(context).settings.arguments as Product != null) {
      Product oldProduct = ModalRoute.of(context).settings.arguments as Product;
      productData.title = oldProduct.title;
      productData.price = oldProduct.price;
      productData.description = oldProduct.description;
      productData.imageUrl = oldProduct.imageUrl;
      liked = oldProduct.isFavorite;
      productData.id = oldProduct.id;
      _imageUrlController.text = oldProduct.imageUrl;
    } else
      status = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final _state = _form.currentState.validate();
    if (!_state) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isDone = true;
    });
    Product product = new Product(
        id: productData.id,
        title: productData.title,
        imageUrl: productData.imageUrl,
        description: productData.description,
        price: productData.price,
        isFavorite: liked);

    if (product.id == "") {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(product);
      } catch (error) {
        return await showDialog<Null>(
            context: context,
            builder: (context) => AlertDialog(
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.redAccent)),
                        child: Text("Ok"))
                  ],
                  title: Text("Error!!"),
                  content: Text("Opps Something went wrong!!"),
                ));
      } finally {
        setState(() {
          isDone = false;
          Navigator.of(context).pop();
        });
      }
    }
    else {
      setState(() {
        isDone = true;
      });
      await Provider.of<Products>(context, listen: false).updateProduct(product.id, product)
          .then((_) => {isDone = false}
      );
      setState(() {
      });
      Navigator.of(context).pop();
    }
  }

  void updateState() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Product"),
        ),
        body: isDone
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 15),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Title",
                          ),
                          initialValue: productData.title,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          onSaved: (value) {
                            productData.title = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter the Product title";
                            } else
                              return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 15),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Price",
                          ),
                          initialValue: productData.price == null
                              ? ""
                              : productData.price.toString(),
                          textInputAction: TextInputAction.next,
                          focusNode: _priceFocusNode,
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode);
                          },
                          onSaved: (value) {
                            productData.price = double.parse(value);
                          },
                          validator: (value) {
                            if (double.parse(value) <= 0)
                              return "Please enter a proper price";
                            if (value.isEmpty)
                              return "Please enter the price";
                            else
                              return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 15),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Description",
                          ),
                          initialValue: productData.description,
                          focusNode: _descriptionFocusNode,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          onSaved: (value) {
                            productData.description = value;
                          },
                          validator: (value) {
                            if (value.isEmpty)
                              return "Please enter product details";
                            if (value.length < 10)
                              return "Description is too short";
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 10, right: 5),
                        child: Row(
                          children: [
                            PhysicalModel(
                              child: Container(
                                height: 100,
                                width: 100,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey)),
                                child: _imageUrlController.text.isEmpty
                                    ? Center(
                                        child: Text("Input URL"),
                                      )
                                    : FittedBox(
                                        child: Image.network(
                                            _imageUrlController.text),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              color: Colors.grey,
                              shadowColor: Colors.black,
                              elevation: 8,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: "ImageUrl",
                                  ),
                                  keyboardType: TextInputType.url,
                                  controller: _imageUrlController,
                                  focusNode: _imageUrlFocusNode,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    _saveForm();
                                    setState(() {});
                                  },
                                  onSaved: (value) {
                                    productData.imageUrl = value;
                                  },
                                  validator: (value) {
                                    if (value.isEmpty)
                                      return "Please give and Image Url";
                                    if (!value.startsWith("http") &&
                                        !value.startsWith("https"))
                                      return "Please provide a valid Image Url";
                                    // if(!value.endsWith(".png") && !value.endsWith(".jpg") && !value.endsWith(".jpeg"))
                                    //   return "Please provide a valid Image Url";
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 30, top: 30),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Save",
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.only(
                                      right: 20, left: 20, top: 5, bottom: 5))),
                          onPressed: _saveForm,
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class ProductData {
  String title, imageUrl, description, id = "";
  double price;

  ProductData({
    @required this.title,
    @required this.price,
    @required this.description,
    @required this.imageUrl,
  });
}
