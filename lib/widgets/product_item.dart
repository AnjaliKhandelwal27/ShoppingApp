import 'package:flutter/material.dart';
import '../screens/product_details_screen.dart';
import 'package:provider/provider.dart';
import '../provider/product.dart';
import '../provider/cart.dart';
import '../provider/auth.dart';

class ProductItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final product=Provider.of<Product>(context,listen:false);
    final cart=Provider.of<Cart>(context,listen: false);
    final authData=Provider.of<Auth>(context,listen:false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),

      child: GridTile(
        child: GestureDetector(
           onTap: (){
             Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,arguments: product.id);
           },
            child: Image.network(product.imageUrl,fit: BoxFit.cover,)),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context,product,_) => IconButton(
              icon: Icon(product.isFavorite? Icons.favorite: Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed:() {
                product.toggleisFavorite(authData.token,authData.userId);

              },
          ) ,
          ),
          title: Text(product.title),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).accentColor,
            onPressed: (){
              cart.addItem(product.id ,product.title, product.price);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Added item to the cart!'),
               duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: (){
                    cart.removeSingleItem(product.id);
                },
              )


              ,) );
            },
          ),
        ),
      ),
    );
  }
}
