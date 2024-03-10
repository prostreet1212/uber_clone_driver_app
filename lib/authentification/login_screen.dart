import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_driver_app/authentification/signup_screen.dart';
import 'package:uber_clone_driver_app/pages/dashboard.dart';
import '../global/global_var.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() async {
    await cMethods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains('@')) {
      cMethods.displaySnackBar('please write valid email', context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(
          'your password must be atleast 8 or more characters', context);
    } else {
      //register user
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) =>
          LoadingDialog(messageText: 'Allowing  you to Login...'),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
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

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)['blockStatus'] == 'no') {
            //userName=(snap.snapshot.value as Map)['name'];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => Dashboard()),
            );
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar(
                'your are blocked. Contact admin: prostreet1212@gmail.com',
                context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar(
              'your record do not exists as a Driver', context);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    emailTextEditingController.text='prostreet1212@gmail.com';
    //emailTextEditingController.text='voditel@kdrc.ru';
    passwordTextEditingController.text='12345678';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 50,),
              Image.asset('assets/images/uberexec.png',width:200 ,),
              const SizedBox(height: 30,),
              Text(
                'Login as a Driver',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10)),
                      child: const Text('Login'),
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
                  'Don\'t have an Account? Register Here',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SignUpScreen()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
