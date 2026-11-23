import 'package:flutter/material.dart';

class WhiteScaffold extends StatelessWidget {
  const WhiteScaffold({super.key,
    required this.child,
    this.showAppBar = false,
    this.appBar,
  });

  final Widget child;
  final bool showAppBar;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (showAppBar) ? appBar : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: child,
      ),
    );
  }
}