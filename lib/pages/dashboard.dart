import 'package:flutter/material.dart';
import 'package:uber_clone_driver_app/pages/earnings_page.dart';
import 'package:uber_clone_driver_app/pages/home_page.dart';
import 'package:uber_clone_driver_app/pages/profile_page.dart';
import 'package:uber_clone_driver_app/pages/trips_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int indexSelected = 0;

  onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          EarningsPage(),
          TripsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),
          label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card),
              label: 'Earninigs'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree),
              label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person),
              label: 'Profile'),
        ],
        currentIndex: indexSelected,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.pink,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
        //backgroundColor: Colors.grey,
      ),
    );
  }
}
