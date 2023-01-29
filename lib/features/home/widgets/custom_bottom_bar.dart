import 'package:flutter/material.dart';
import 'package:social_media/core/common/animated_button.dart';

// Standard spotify tab bar height.
const double _kTabBarHeight = 50;

class CustomBottomNavBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final Colors? backgroundColor;
  final double height;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.backgroundColor,
    this.height = _kTabBarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: height + bottomPadding,
      decoration: BoxDecoration(
        // color: Pallete.intaBlack,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade900,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Semantics(
          explicitChildNodes: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _buildNavItem(
                icon: Icons.home,
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                icon: Icons.search,
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                icon: Icons.add_circle,
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _buildNavItem(
                icon: Icons.favorite,
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _buildNavItem(
                icon: Icons.person,
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon,
      String? title,
      required bool isSelected,
      required VoidCallback onTap}) {
    return MouseRegion(
      cursor: MouseCursor.defer,
      child: Bounceable2(
        hitTestBehavior: HitTestBehavior.opaque,
        scaleFactor: 0.6,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Icon(
                  icon,
                  // color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                      // color: isSelected ? Colors.blue : Colors.grey,
                      ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
