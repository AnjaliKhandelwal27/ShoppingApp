import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../provider/product_provider.dart';
import '../widgets/user_product_item.dart';
import '../screens/edit_products_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = './userProducts';

  Future<void> onRefresh(BuildContext context) async{
    await Provider.of<ProductProvider>(context,listen: false).fetchAndAdd(true);
  }

  @override
  Widget build(BuildContext context) {
//    final product = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: onRefresh(context),
        builder:(context,snapshot)=> snapshot.connectionState==ConnectionState.waiting?Center(child: CircularProgressIndicator(),):RefreshIndicator(
          onRefresh:()=>onRefresh(context)  ,
          child: Consumer<ProductProvider>(
            builder: (context,product,_)=>
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: ListView.builder(
                itemBuilder: (_, index) => Column(
                  children:[
                  UserProductItem(
                    id: product.items[index].id,
                    title: product.items[index].title,
                    imageUrl: product.items[index].imageUrl,

                  ),
                    Divider(),
                  ] ,
                ),
                itemCount: product.items.length,
            ),
             ),
          ),
        ),
      ),
    );
  }
}
