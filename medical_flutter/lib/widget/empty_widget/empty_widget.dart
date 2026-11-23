import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class EmptyStateBanner extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  const EmptyStateBanner({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.notifications_none_rounded,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final base = context.base;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: base * 0.06),
        padding: EdgeInsets.symmetric(
          vertical: base * 0.06,
          horizontal: base * 0.05,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(base * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: base * 0.05,
              offset: Offset(0, base * 0.02),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: base * 0.15,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: base * 0.04),

            Text(
              title,
              style: TextStyle(
                fontSize: base * 0.045,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: base * 0.02),

            Text(
              message,
              style: TextStyle(
                fontSize: base * 0.035,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRefresh != null) ...[
              SizedBox(height: base * 0.05),
              SizedBox(
                width: base * 0.4,
                child: ElevatedButton(
                  onPressed: onRefresh,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: base * 0.03,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(base * 0.04),
                    ),
                  ),
                  child: Text(
                    "Tải lại",
                    style: TextStyle(fontSize: base * 0.035),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}