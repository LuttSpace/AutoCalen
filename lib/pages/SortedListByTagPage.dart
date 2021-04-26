
import 'package:autocalen/models/Tag.dart';
import 'package:autocalen/models/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SortedListByTag extends StatefulWidget{
  @override
  _SortedListByTagState createState() => _SortedListByTagState();
}

class _SortedListByTagState extends State<SortedListByTag> {
  var userProvider;
  @override
  void initState() {
    userProvider = Provider.of<UserData>(context, listen: false);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black
    ),
    home: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text('태그 목록'),
          leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: ()=> Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('UserList').doc(userProvider.getUid()).collection('TagHub').snapshots(),
          builder: (context, snapshot) {
            if(snapshot.data==null) {
              print('isEmpty ${snapshot.data}');
              return Center(child: Text('로딩'));
            }
            else{
              List<DocumentSnapshot> documents = snapshot.data.docs;
              return GridView(
                padding: EdgeInsets.all(30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: documents.map((eachDocument) => TagTile(new Tag(eachDocument.id, eachDocument['name'],
                    Color(int.parse(eachDocument['color'].toString().substring(6, 16)))),userProvider)).toList(),
              );
            }
          }
      ),
    )
    );
  }
}
class TagTile extends StatefulWidget{
  TagTile(this._tag,this.userProvider);
  final userProvider;
  final Tag _tag;

  @override
  _TagTileState createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GridTile(
          child: Container(
            decoration: BoxDecoration(
                //color: widget._tag.getTagColor(), // 골라달라!
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color:Color(0xff474747),width: 0.5),
            ),
            child: ElevatedButton(
               style: ElevatedButton.styleFrom(
                 primary: Colors.transparent,
                 onPrimary: Colors.black,
                 elevation: 0,
                 shadowColor: Colors.transparent,
               ),
                onPressed: (){

                },
                child: Center(
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 20,horizontal: 0),
                          width: 70,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget._tag.getTagColor(),
                            borderRadius: BorderRadius.circular(5)
                          ),
                      ),
                      Text(widget._tag.getTagName()),
                    ],
                  ),
                )
            ),
          ),
        )
    );
  }
}