import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fanpage_kk/services/auth.dart';
import 'package:flutter_fanpage_kk/user_login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'detailed_info.dart';
import 'user_register_screen.dart';

class Main_Screen extends StatefulWidget {
  const Main_Screen({Key? key}) : super(key: key);
  // Main_Screen(this.role);

  @override
  _Main_ScreenState createState() => _Main_ScreenState();
}

class _Main_ScreenState extends State<Main_Screen> {
  File? _image;

  String id =Authentication().getUserId();
  final FirebaseFirestore fb = FirebaseFirestore.instance;
  String age = '';
  String bio = '';
  String img = '';
  String hometown ='';
  String name = '';

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference messages =
      FirebaseFirestore.instance.collection("messages");

  final Stream<QuerySnapshot> _messageStream =
      FirebaseFirestore.instance.collection('messages').snapshots();

  String role = "";

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // user is null
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const User_Register()));
      } else {
        // fetch user role
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          setState(() {
            role = documentSnapshot['role'];
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: Colors.blue,
            centerTitle: true,
            title:const Text("Customer Main Screen"),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text("Want to Logout?",
                                  textAlign: TextAlign.center),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      {Navigator.of(context).pop()},
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                User_Login()));
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ));
                  },
                  child: const Icon(Icons.logout),
                ),
              )
            ],
            automaticallyImplyLeading: false),

        // body
        body:

            StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                   child: CircularProgressIndicator(),
                );
              }
               return ListView(
                 children: snapshot.data!.docs.map((document) {

                 return Container(
                    height: 250,
                    decoration: const BoxDecoration(
                       borderRadius: BorderRadius.vertical(),
                        color: Colors.yellow,
                     ),
                    child: ListView(
                      children: <Widget>[
                          Container(
                            child:
                              document['url'].toString().length > 1 ?
                              Image.network(document['url'], height: 100, width: 100,) :
                              Image.asset('assets/MyImage.jpeg', height: 50, width: 50,),
                          ),
                        Container(
                          child: Text( document['firstName']),
                          padding: EdgeInsets.all(6),
                        ),
                        Container(
                          child: Text( document['date jioned'].toString()),
                          padding: EdgeInsets.all(2),
                        ),

                        Container(
                          child: ElevatedButton.icon(
                              onPressed: () async {
                                setState(() {
                                   age=  document['age'];
                                     bio = document['bio'];
                                     hometown= document['hometown'];
                                    name= document['firstName'];
                                     img = document['url'];
                                });
                                Navigator.push(
                                    context,MaterialPageRoute(builder: (context) =>
                                    DetailedInfo(age,
                                      img,
                                      name,
                                      bio,
                                      hometown,
                                    )));
                               //
                              },
                              icon: Icon(Icons.account_circle_outlined ) , label: Text('Click Here for More Details')),
                        )

                      ]
                     ),
                    margin:EdgeInsets.all(5.0),

                );

                }).toList(),
                );
            },
            ),
        
    );
    }
    Future getImage(bool gallery) async {
    ImagePicker imagePicker = ImagePicker();
    XFile image;
    // Let user select photo from gallery
    if(gallery) {
      image = (await imagePicker.pickImage(
        source: ImageSource.gallery,imageQuality: 50))!;
    }
    // Otherwise open camera to get new photo
    else{
      image = (await imagePicker.pickImage(
        source: ImageSource.camera,imageQuality: 50))!;
    }
    setState(() {
         _image = File(image.path); // Use if you only need a single picture\
          addImage(_image);
    });
  }

  Future<void> addImage(img) async {
    User user = Authentication().getAuthUser();
    String id = user.uid;
    var storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child(id)
        .putFile(img);
    if (snapshot.state == TaskState.success) {
      final String downloadUrl =
      await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update({"url": downloadUrl});
      setState(() {

      });
    }

  }
    
}

