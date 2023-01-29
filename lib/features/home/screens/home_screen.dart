import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/core/constants/constants.dart';
import 'package:social_media/features/home/drawers/profile_drawer.dart';
import 'package:social_media/features/home/widgets/custom_bottom_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // selected position for bottom navigation bar.
  int _page = 0;

  // To display endDrawer
  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(index: _page, children: Constants.tabWidgets),
      endDrawer: const ProfileDrawer(),
      bottomNavigationBar:
          CustomBottomNavBar(selectedIndex: _page, onTap: onPageChanged),
    );
  }
}


// bottomNavigationBar: CupertinoTabBar(
//         backgroundColor: Colors.black.withAlpha(34),
//         activeColor: IconTheme.of(context).color,
//         onTap: onPageChanged,
//         currentIndex: _page,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add_circle),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//           ),
//         ],
//       ),