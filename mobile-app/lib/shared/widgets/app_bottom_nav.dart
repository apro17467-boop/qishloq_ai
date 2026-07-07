import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/listings');
        break;
      case 2:
        context.go('/create-listing');
        break;
      case 3:
        context.go('/ai-advice');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey[500],
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Bosh',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 1 ? Icons.list_alt : Icons.list_alt_outlined),
            label: 'E’lonlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 2 ? Icons.add_circle : Icons.add_circle_outline),
            label: 'Joylash',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 3 ? Icons.smart_toy : Icons.smart_toy_outlined),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 4 ? Icons.person : Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
