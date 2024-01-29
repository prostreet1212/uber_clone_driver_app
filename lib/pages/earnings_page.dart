import 'package:flutter/material.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({Key? key}) : super(key: key);

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Text('earnings',style: TextStyle(color:Colors.white,
            fontSize: 24),),
      ) ,
    );
  }
}