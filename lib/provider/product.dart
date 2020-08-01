import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier{

  final String id;
  final String title;
  final double price;
  final String description;
  bool isFavorite;
  final String imageUrl;

  Product({
    @required this.id,
    @required this.title,
    @required this.imageUrl,
    @required this.description,
    @required this.price,
    this.isFavorite=false,
  });
   void _setStatus(bool newValue){
     isFavorite=newValue;
     notifyListeners();

   }

  Future<void> toggleisFavorite(String token,String userId) async {
    final oldStatus=isFavorite;
    isFavorite=!isFavorite;
    notifyListeners();
    final url='https://shopping-app-571f9.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try{
      final response=await http.put(url,body: json.encode(
        isFavorite
      ),);
      if(response.statusCode>=400){
         _setStatus(oldStatus);
      }
    }catch(error){
      _setStatus(oldStatus);
    }
  }
}