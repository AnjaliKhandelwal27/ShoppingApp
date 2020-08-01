import 'package:flutter/material.dart';
import 'product_item.dart';
import '../provider/product_provider.dart';
import 'package:provider/provider.dart';
import '../provider/product.dart';


class ProductGrid extends StatelessWidget {
  final bool showFav;
  ProductGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final productData=Provider.of<ProductProvider>(context);

    final product=showFav ? productData.favoriteOnly :  productData.items;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5/4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),

      itemBuilder:( context,index){
        return ChangeNotifierProvider.value(
          value: product[index],
          child: ProductItem(

          ),
        );

      },
      itemCount: product.length,
    );
  }
}
