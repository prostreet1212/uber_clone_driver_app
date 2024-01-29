import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget{
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {

  TabController? controller;
  int indexSelected=0;

  onBarItemClicked(int i){
    setState(() {
      indexSelected=i;
      controller!.index=indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller=TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [

        ]);
  }
}
