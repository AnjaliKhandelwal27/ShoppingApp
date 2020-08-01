import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';
import 'product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
//    Product(
//      id: 'p1',
//      title: 'Red Shirt',
//      description: 'A red shirt - it is pretty red!',
//      price: 29.99,
//      imageUrl:
//          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

   final String token;
   final String id;
   ProductProvider(this.token,this._items,this.id);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteOnly {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://shopping-app-571f9.firebaseio.com/products.json?auth=$token';
    try{
      final response=await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId':id

          }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,

      );
      _items.add(newProduct);
      notifyListeners();
    } catch(error){
      throw error;
    }

  }

  Future<void> fetchAndAdd([bool filterUser=false]) async{
    final filterSet=filterUser?'orderBy="creatorId"&equalTo="$id"':'';
    var url='https://shopping-app-571f9.firebaseio.com/products.json?auth=$token&$filterSet';

     try{
       final response=await http.get(url);
       final List<Product> loadedProducts=[];
       final extractedProduct=json.decode(response.body) as Map<String,dynamic>;
       if(extractedProduct==null)
         return;
       url='https://shopping-app-571f9.firebaseio.com/userFavorites/$id.json?auth=$token';
       final favoriteResponse=await http.get(url);
       final favoriteDate=json.decode(favoriteResponse.body);
       extractedProduct.forEach((prodId,prodData) {
         loadedProducts.add(Product(
           id: prodId,
           title: prodData['title'],
           description: prodData['description'],
           imageUrl: prodData['imageUrl'],
           price: prodData['price'],
           isFavorite: favoriteDate==null? false : favoriteDate[prodId] ?? false,
           
         )
         );

       });
       _items=loadedProducts;
       notifyListeners();

     }catch(error){
       throw error;
     }

  }

  void updateProduct(String id, Product newProduct)async {
    final proIndex = _items.indexWhere((prodId) => prodId.id == id);
    if (proIndex >=0) {
      final url='https://shopping-app-571f9.firebaseio.com/products/$id.json?auth=$token';
      await http.patch(url,body: json.encode({
          'title':newProduct.title,
        'price':newProduct.price,
        'imageUrl':newProduct.imageUrl,
        'description':newProduct.description
      }));
      _items[proIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteItem(String id) async {
    final url='https://shopping-app-571f9.firebaseio.com/products/$id.json?auth=$token';
    final existingProductId=_items.indexWhere((prodId) => prodId.id == id);
    var existingProduct=_items[existingProductId];

    _items.removeAt(existingProductId);
    notifyListeners();
    final response=await http.delete(url);
      if(response.statusCode>=400){
        _items.insert(existingProductId, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete product');
      }
        existingProduct=null;


  }
}
