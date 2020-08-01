import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String title;
  final String productId;
  final double price;
  final double quantity;

  CartItem({
    this.quantity,
    this.price,
    this.title,
    this.productId,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
              size: 50,
        ),
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction){
         return showDialog(context: context,builder: (context)=>AlertDialog(
            title: Text('Are you sure?'),
           content: Text('Do you want to delete the item?'),
           actions: [
              FlatButton(
                child: Text('No'),
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
              ),
             FlatButton(
               child: Text('Yes'),
               onPressed: (){
                 Navigator.of(context).pop(true);
               },
             ),

           ],
         ),);
      },
      onDismissed: (direction){
        Provider.of<Cart>(context,listen: false).removeItem(productId);
      },


      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(

                    child: Text('$price')),
              ),

            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price*quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
