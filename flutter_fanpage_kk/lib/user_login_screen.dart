import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_fanpage_kk/main_screen.dart';
import 'package:flutter_fanpage_kk/services/auth.dart';
import 'package:flutter_fanpage_kk/services/google_signin.dart';
import 'package:flutter_fanpage_kk/user_register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:sign_button/sign_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';


var instance= Authentication();
String _verid='';

class User_Login extends StatefulWidget {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController textFieldController = TextEditingController();

  @override
  _User_LoginState createState() => _User_LoginState();
}

class _User_LoginState extends State<User_Login> {
  final _formKey = GlobalKey<FormState>();

  var _email = "";
  var _password = "";
  var userCredentialsObj;
  var _role = "";
  
  // create firebae instance
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  Future<void> _displayPhoneTextInputDialog(BuildContext context) async {
    TextEditingController phone= TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:Text('Enter your Phone Number'),
            content:Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    //valueText = value;
                  });
                },
                controller: phone,
                decoration: InputDecoration(hintText: "Enter Phone"),
              ),
              Expanded(child:
              OTPTextField(
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 30,
                fieldStyle: FieldStyle.underline,
                outlineBorderRadius: 10,
                style: TextStyle(fontSize: 20),
                onChanged: (pin) {
                  print("Changed: " + pin);
                },
                onCompleted: (pin) {
                  instance.verify(pin,_verid).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Main_Screen())));
                },
              ),)
          ]
            ),

            actions:[Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:<Widget>[

              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>User_Login()));
                  });
                },
              ),
            FlatButton(
              color: Colors.blueAccent,
              textColor: Colors.white,
              child: Text('Get Code'),
              onPressed: () {
                setState(()  {
                  _verid= instance.send_code(phone.text.trim()).toString();
                });
              },
            ),

            ],
          )]);
        });
  }
  Future<void> _displayEmailInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:Text('Enter your Email address'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  //valueText = value;
                });
              },
              decoration: InputDecoration(hintText: "Email address"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>User_Login()));
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState((){
                    // TextEditingController textFieldController = TextEditingController();
                    // instance.signInEmail(textFieldController.text,context);
                    

                  });Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Main_Screen()));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("FanPage Login"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // text field for email
                TextFormField(
                  decoration: const InputDecoration(hintText: "Email"),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.emailAddress,

                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      _email = val.trim();
                    });
                  },
                ),

                // text field for password
                TextFormField(
                  decoration: const InputDecoration(hintText: "Password"),
                  textAlign: TextAlign.start,

                  obscureText: true,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },

                  onChanged: (val) {
                    setState(() {
                      _password = val.trim();
                    });
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      // print(_formKey.currentState);
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("please wait while we check ur entry..")),
                        );

                        // signin with email and password using firebase APIs
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                                  email: _email, password: _password);

                          userCredentialsObj = userCredential;
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("There is no User by this Email")),
                            );
                          } else if (e.code == 'wrong-password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Password is Wrong...Do Try Again")),
                            );
                          }
                        }

                        // check if user is ADMIN OR CUSTOMER
                        FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: _email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var i = 0; i < querySnapshot.docs.length; i++) {
                            var doc = querySnapshot.docs[i];

                            //Finding Admin
                            if (doc["role"].toString() == "ADMIN") {
                              _role = doc["role"].toString();
                              break;
                            }
                          }

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>const Main_Screen()));
                        });
                      }
                    },
                    child: const Text('Log In'),
                  ),
                ),
                ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                elevation: 1,
                                minimumSize: Size(double.infinity, 50)
                              ),
                              icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                              label: Text('Log in with Google'),
                              onPressed: () async {
                                
                                User? user = await GoogleSignInService().signInWithGoogle(context: context);
                                await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
                                  'uid': user.uid,
                                  'email': user.email,
                                  'firstName': user.displayName.toString(),
                                  'role' : 'user',
                                  'date jioned': DateTime.now(),
                                  'url':"https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png"
                                });
                                if(user != null){
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Main_Screen()));
                                }
                              },
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                elevation: 1,
                                minimumSize: Size(double.infinity, 50)
                              ),
                              icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                              label: Text('Log in with Facebook'),
                              onPressed: () async {
                                 Authentication().signInWithFacebook().then((UserCredential value){ 
                                   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Main_Screen()));
                              });}
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                elevation: 1,
                                minimumSize: Size(double.infinity, 50)
                              ),
                              icon: Icon(Icons.account_circle),
                              label: Text('Log in Anonymously'),
                              onPressed: () async {
                                Authentication().anonymous(context);
                              }
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                elevation: 1,
                                minimumSize: Size(double.infinity, 50)
                              ),
                              icon: const FaIcon(FontAwesomeIcons.mailBulk, color: Colors.blue),
                              label: const Text('Log in with only Mail Id'),
                              onPressed: () async {_displayEmailInputDialog(context);}),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                elevation: 1,
                                minimumSize: Size(double.infinity, 50)
                              ),
                              icon: FaIcon(FontAwesomeIcons.phoneSquareAlt, color: Colors.blue),
                              label: Text('Log in with phone Number'),
                              onPressed: () async {_displayPhoneTextInputDialog(context);}),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const User_Register()));
                  },
                  child: const Text("Click here to Register",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                      )),
                )
              ],
            ),
          )),
    );
  }
}
