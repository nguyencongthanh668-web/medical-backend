import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class InfoCard extends StatelessWidget {
  final List<Widget> children;

  const InfoCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final base = context.base;

    return Container(
      margin: EdgeInsets.symmetric(vertical: base * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(base * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: base * 0.04,
            offset: Offset(0, base * 0.015),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isLast;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = context.base;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: base * 0.05,
            vertical: base * 0.045,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: base * 0.038,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: base * 0.04,
                    fontWeight: FontWeight.w600,
                    color: highlight
                        ? const Color(0xFF4A90E2)
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
      ],
    );
  }
}

