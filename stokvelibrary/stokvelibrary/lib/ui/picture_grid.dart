import 'package:flutter/material.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class PictureGrid extends StatelessWidget {
  final StokvelGoal stokvelGoal;

  const PictureGrid({Key key, this.stokvelGoal}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Goal Images and Video', style: Styles.whiteSmall,),
        bottom: PreferredSize(child: Column(
          children: <Widget>[
            Text(stokvelGoal.name, style: Styles.whiteBoldSmall,),
            SizedBox(height: 8,),
            Text(stokvelGoal.stokvel.name,style: Styles.whiteBoldMedium,),
            SizedBox(height: 12,)
          ],
        ), preferredSize: Size.fromHeight(80)),
      ),
      body:  GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: stokvelGoal.imageUrls.length,
          itemBuilder: (context, index) {
            return GridTile(
                child: Image.network(
                  stokvelGoal.imageUrls.elementAt(index),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ));
          }),
    );
  }
}
