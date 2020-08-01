import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/product_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = './productDetailsScreen';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<ProductProvider>(context, listen: false)
        .findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              child: Image.network(loadedProduct.imageUrl,fit: BoxFit.cover,),
            ),
            SizedBox(
              height: 10,
            ),
            Text('\$${loadedProduct.price}',style: TextStyle(
              color: Colors.grey
            ),),
            Container(
              width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Text(loadedProduct.description,
                textAlign: TextAlign.center,),
            ),


          ],
        ),
      ),
    );
  }
}
