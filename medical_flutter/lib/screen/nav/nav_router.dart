import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/home/home_screen.dart';
import 'package:medical_device_tracking/screen/notification/notification_screen.dart';
import 'package:medical_device_tracking/screen/profile/profile_screen.dart';
import 'package:medical_device_tracking/screen/statistical/statistical_screen.dart';

class NavRouter extends StatefulWidget {
  const NavRouter({super.key});

  @override
  State<NavRouter> createState() => _NavRouterState();
}

class _NavRouterState extends State<NavRouter> {
  int currentPage = 0;

  final pages = [
    const HomeScreen(),
    const StatisticalScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.base * 0.18,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, 0, Icons.home_rounded, "Trang chủ"),
          _navItem(context, 1, Icons.analytics_outlined, 'Thống kê'),
          _navItem(context, 2, Icons.notifications, 'Thông báo'),
          _navItem(context, 3, Icons.person_rounded, "Cá nhân"),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      int index,
      IconData icon,
      String label,
      ) {
    final isActive = currentIndex == index;
    final color =
    isActive ? Color(0xFF2D82B7) : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Padding(
        padding: context.pxy(0.04, 0.01),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: context.base * 0.068,
            ),
            SizedBox(height: context.base * 0.02 / 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: context.base * 0.034,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}