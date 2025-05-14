import 'package:drivers/tabPages/earning_tab.dart';
import 'package:drivers/tabPages/home_tab.dart';
import 'package:drivers/tabPages/profile_tab.dart';
import 'package:drivers/tabPages/ratings_tab.dart';
import 'package:flutter/material.dart';
import 'package:drivers/tabPages/scheduled_rides_tab.dart';
 // создаёшь эту страницу


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{

  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState(){
    super.initState();

    tabController = TabController(length: 5, vsync: this);
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          ScheduledRidesTabPage(),
          EarningsTabPage(),
          RatingsTabPage(),
          ProfileTabPage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Нүүр"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Төлөвлөсөн"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Орлого"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Үнэлгээ"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Бүртгэл "),
        ],
        
        unselectedItemColor:Colors.white54,
        selectedItemColor:Colors.white,
        backgroundColor:Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
        ),
    );
  }
}