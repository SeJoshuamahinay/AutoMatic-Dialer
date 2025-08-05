import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'front_end_view.dart';
import 'mid_range_view.dart';
import 'hardcore_view.dart';
import 'dashboard_view.dart';
import 'settings_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 2);
  }

  List<Widget> _buildScreens() {
    return [
      const FrontEndView(),
      const MidRangeView(),
      const DashboardView(),
      const HardcoreView(),
      const SettingsView(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.phone),
        title: "Front End",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.blueAccent,
        inactiveColorSecondary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.phone_forwarded),
        title: "Mid Range",
        activeColorPrimary: Colors.orange,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.blueAccent,
        inactiveColorSecondary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.dashboard),
        title: "Dashboard",
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.blueAccent,
        inactiveColorSecondary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.phone_callback),
        title: "Hardcore",
        activeColorPrimary: Colors.red,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.blueAccent,
        inactiveColorSecondary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: "Settings",
        activeColorPrimary: Colors.purple,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.blueAccent,
        inactiveColorSecondary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
