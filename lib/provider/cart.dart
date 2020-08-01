import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final double quantity;
  CartItem({
    @required this.title,
    @required this.id,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items={};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemcount{
    return _items.length;
  }

  double get totalAmount{
    double total=-1;
   _items.forEach((key, cartItem) {
     total=total+cartItem.price*cartItem.quantity;
   });
   return total+1;
  }

  void removeSingleItem(String id){
    if(!_items.containsKey(id))
        return;
    if(items[id].quantity>1){
        _items.update(id, (existingitem) =>CartItem(
          id: existingitem.id,
          title: existingitem.title,
          price: existingitem.price,
          quantity: existingitem.quantity-1,
        ));
    }
    else{
      _items.remove(id);
    }
  }

  void addItem(String id, String title, double price) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (existingValue) => CartItem(
                id: existingValue.id,
                price: existingValue.price,
                title: existingValue.title,
                quantity: existingValue.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          id,
          () => CartItem(
                id: DateTime.now().toString(),
                price: price,
                title: title,
                quantity: 1,
              ));
    }
    notifyListeners();
  }
  void removeItem(String id){
    _items.remove(id);
    notifyListeners();
  }
  void clear() {
    _items={};
    notifyListeners();
  }
}
