import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../provider/product.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = './editProductScreen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _formkey = GlobalKey<FormState>();
  var editingProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var isInit = true;
  var isLoading = false;
  var initialValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocus.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        editingProduct =
            Provider.of<ProductProvider>(context).findById(productId);
        initialValues = {
          'title': editingProduct.title,
          'price': editingProduct.price.toString(),
          'description': editingProduct.description,
          'imageUrl': '',
        };
        _imageUrlController.text = editingProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void _saveform() async {
    final isValid = _formkey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formkey.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (editingProduct.id != null) {

      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(editingProduct.id, editingProduct);

    } else {
          try{
            await Provider.of<ProductProvider>(context, listen: false)
                .addProduct(editingProduct);
          }
    catch (error){
            await showDialog(context: context,builder:(context)=> AlertDialog(
             title: Text('An error occurred'),
              content: Text('Something went wrong!'),
              actions: [
                FlatButton(
                  child: Text('OKAY'),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
      }

    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlFocus.removeListener(_updateImage);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocus.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageUrlFocus.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveform,
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formkey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: initialValues['title'],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please provide a value';
                        return null;
                      },
                      onSaved: (value) {
                        editingProduct = Product(
                          id: editingProduct.id,
                          isFavorite: editingProduct.isFavorite,
                          title: value,
                          description: editingProduct.description,
                          price: editingProduct.price,
                          imageUrl: editingProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: initialValues['price'],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a price';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid price';
                        if (double.parse(value) <= 0)
                          return 'Please enter a value greater than zero';
                        return null;
                      },
                      onSaved: (value) {
                        editingProduct = Product(
                          id: editingProduct.id,
                          isFavorite: editingProduct.isFavorite,
                          title: editingProduct.title,
                          description: editingProduct.description,
                          price: double.parse(value),
                          imageUrl: editingProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: initialValues['description'],
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a value';
                        if (value.length < 10)
                          return 'Please enter atleast 10 characters';
                        return null;
                      },
                      onSaved: (value) {
                        editingProduct = Product(
                          id: editingProduct.id,
                          isFavorite: editingProduct.isFavorite,
                          title: editingProduct.title,
                          description: value,
                          price: editingProduct.price,
                          imageUrl: editingProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8, right: 10),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocus,
                            onFieldSubmitted: (_) {
                              _saveform();
                            },
                            validator: (value) {
                              if (value.isEmpty) return 'Please enter a URL';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Please enter a valid URL';
                              if (!value.endsWith('png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('jpeg'))
                                return 'Please enter a image URL';
                              return null;
                            },
                            onSaved: (value) {
                              editingProduct = Product(
                                id: editingProduct.id,
                                isFavorite: editingProduct.isFavorite,
                                title: editingProduct.title,
                                description: editingProduct.description,
                                price: editingProduct.price,
                                imageUrl: value,
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
