import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_driver_app/authentification/login_screen.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  TextEditingController nameTextEditingController=TextEditingController();
  TextEditingController phoneTextEditingController=TextEditingController();
  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController carTextEditingController=TextEditingController();

  setDriverInfo(){
    setState(() {
      nameTextEditingController.text=driverName;
      phoneTextEditingController.text=driverPhone;
      emailTextEditingController.text=FirebaseAuth.instance.currentUser!.email.toString();
      carTextEditingController.text=carNumber+' - '+carColor+' - '+carModel;
    });
  }

  @override
  void initState() {
    super.initState();
    setDriverInfo();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //image
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: NetworkImage(driverPhoto),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              //driver name
              Padding(
                padding: const EdgeInsets.only(left: 25.0,right: 25,top: 8),
                child: TextField(
                  controller: nameTextEditingController,
                    textAlign: TextAlign.center,
                    enabled: false,
                style: TextStyle(fontSize: 16,color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(Icons.person,
                  color:Colors.white,)
                ),
                ),
              ),
              //driver phone
              Padding(
                padding: const EdgeInsets.only(left: 25.0,right: 25,top: 4),
                child: TextField(
                  controller: phoneTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: TextStyle(fontSize: 16,color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.phone_android_outlined,
                        color:Colors.white,)
                  ),
                ),
              ),
              //driver email
              Padding(
                padding: const EdgeInsets.only(left: 25.0,right: 25,top: 4),
                child: TextField(
                  controller: emailTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: TextStyle(fontSize: 16,color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.email,
                        color:Colors.white,)
                  ),
                ),
              ),
              //driver car info
              Padding(
                padding: const EdgeInsets.only(left: 25.0,right: 25,top: 4),
                child: TextField(
                  controller: carTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: TextStyle(fontSize: 16,color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.drive_eta_rounded,
                        color:Colors.white,)
                  ),
                ),
              ),
              SizedBox(height: 12,),
              //logout btn
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 18)),
                child: const Text('Logout'),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
