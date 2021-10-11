import 'package:flutter/material.dart';

class DetailedInfo extends StatefulWidget{
  final String age;
  final String img;
  final String name;
  final String bio;
  final String hometown;
  DetailedInfo(this.age,this.img,this.name,this.bio,this.hometown);

  @override
  State<StatefulWidget> createState() { return new DetailedInfoState();}
}
class DetailedInfoState extends State<DetailedInfo>{
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("User Page"),
      ),
      backgroundColor:Colors.amberAccent ,
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              child: Text( widget.name,
                  style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 50.0)),
              padding: EdgeInsets.all(30),
            ),
            Container(
              child: widget.img.length > 1 ?
              Image.network(widget.img, height: 200, width: 200,) :
              Image.asset('assets/MyImage.jpeg', height: 200, width: 200,),
            ),
            Container(
              child: Text("Bio: " + widget.bio,
                  style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 20.0)),
              padding: EdgeInsets.all(25),
            ),
            Container(
              child: Text("Age: " + widget.age,
                  style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 20.0)),
              padding: EdgeInsets.all(25),
            ),
            Container(
              child: Text("Hometown: " + widget.hometown,
                  style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 20.0)),
              padding: EdgeInsets.all(25),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        tooltip: 'Log Out',
        child: const Icon(Icons.logout),
      ),
    );

  }


}