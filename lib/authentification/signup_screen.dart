import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_clone_driver_app/pages/dashboard.dart';

import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;

  checkIfNetworkIsAvailable() async {
    await cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length <= 3) {
      cMethods.displaySnackBar(
          'your name must be atleast 4 or more characters', context);
    } else if (userPhoneTextEditingController.text.trim().length <= 7) {
      cMethods.displaySnackBar(
          'your phone must be atleast 8 or more characters', context);
    } else if (!emailTextEditingController.text.contains('@')) {
      cMethods.displaySnackBar('please write valid email', context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(
          'your password must be atleast 8 or more characters', context);
    } else {
      //register user
      registerNewUser();
    }
  }

  registerNewUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) =>
          LoadingDialog(messageText: 'Registering your account...'),
    );
    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
            .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;
    if (!context.mounted) return;
    Navigator.pop(context);
    DatabaseReference usersRef=FirebaseDatabase.instance.ref()
        .child('users').child(userFirebase!.uid);
    Map userDataMap={
      'name':userNameTextEditingController.text.trim(),
      'email':emailTextEditingController.text.trim(),
      'phone':userPhoneTextEditingController.text.trim(),
      'id':userFirebase.uid,
      'blockStatus':'no',
    };
    usersRef.set(userDataMap);
Navigator.push(context, MaterialPageRoute(builder: (c)=>Dashboard()));
  }

  chooseImageFromGallery()async{
    final pickedFile=await  ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      setState(() {
        imageFile=pickedFile;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 40,),
            imageFile==null?
            CircleAvatar(
              radius: 86,
              backgroundImage: AssetImage('assets/images/avatarman.png'),
            ):Container(
              //here
            ),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: (){
                  chooseImageFromGallery();
                },
                child: const Text(
                  'Choose Image ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              //text fields and button
              Padding(
                padding: const EdgeInsets.only(
                  right: 22,
                  left: 22,
                  top: 22,
                  bottom: 14,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'your Name',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Name',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'your Phone',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Phone',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'your Email',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Email',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'your Password',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Password',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'your Car Model',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Car Model',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: vehicleColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'your Car Color',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Car Color',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'your Car Number',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintText: 'your Car Number',
                          hintStyle: TextStyle()),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 22,
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10)),
                      child: const Text('Sign Up'),
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                    )
                  ],
                ),
              ),

              //login? button
              TextButton(
                child: const Text(
                  'Already have an Account? Login Where',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
