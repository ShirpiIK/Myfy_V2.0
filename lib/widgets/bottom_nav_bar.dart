import 'package:flutter/material.dart';

import '../utils/theme.dart';

class BottomNavBar extends StatelessWidget {

  final int currentIndex;

  final Function(int) onTap;

  const BottomNavBar({

    super.key,

    required this.currentIndex,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      decoration: BoxDecoration(

        color: MyfyTheme.darkBackground.withOpacity(0.95),

        border: const Border(

          top: BorderSide(color: MyfyTheme.borderColor, width: 0.5),

        ),

      ),

      child: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: onTap,

        backgroundColor: Colors.transparent,

        elevation: 0,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: MyfyTheme.primaryOrange,

        unselectedItemColor: MyfyTheme.textSecondary,

        selectedFontSize: 12,

        unselectedFontSize: 12,

        items: const [

          BottomNavigationBarItem(

            icon: Icon(Icons.home_rounded),

            label: 'Home',

          ),

          BottomNavigationBarItem(

            icon: Icon(Icons.search_rounded),

            label: 'Search',

          ),

          BottomNavigationBarItem(

            icon: Icon(Icons.library_music_rounded),

            label: 'Library',

          ),

        ],

      ),

    );

  }

}