import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  double get base => MediaQuery.of(this).size.shortestSide;
}

extension ContextPaddingExtension on BuildContext {
  EdgeInsets get pXS => EdgeInsets.all(base * 0.01);
  EdgeInsets get pSM => EdgeInsets.all(base * 0.02);
  EdgeInsets get pMD => EdgeInsets.all(base * 0.03);
  EdgeInsets get pLG => EdgeInsets.all(base * 0.04);
  EdgeInsets get pXL => EdgeInsets.all(base * 0.05);

  EdgeInsets px(double factor) => EdgeInsets.symmetric(horizontal: base * factor);
  EdgeInsets py(double factor) => EdgeInsets.symmetric(vertical: base * factor);

  EdgeInsets pxy(double x, double y) =>
      EdgeInsets.symmetric(horizontal: base * x, vertical: base * y);
  EdgeInsets pOnly(double t, double l, double b, double r) =>
      EdgeInsets.only(
        top: base * t,
        left: base * l,
        right: base * r,
        bottom: base * b,
      );
}

extension ContextBorderRadiusExtension on BuildContext {
  BorderRadius get radiusXS => BorderRadius.circular(base * 0.01);
  BorderRadius get radiusSM => BorderRadius.circular(base * 0.015);
  BorderRadius get radiusMD => BorderRadius.circular(base * 0.02);
  BorderRadius get radiusLG => BorderRadius.circular(base * 0.03);
  BorderRadius get radiusXL => BorderRadius.circular(base * 0.04);

  BorderRadius radius(double factor) =>
      BorderRadius.circular(base * factor);
}
