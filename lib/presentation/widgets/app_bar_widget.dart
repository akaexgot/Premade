import 'package:flutter/material.dart';

/// AppBar customizado con Material Design 3
class AppBarWidget extends AppBar {
  AppBarWidget({
    super.key,
    required String title,
    super.actions,
    super.leading,
    bool super.centerTitle = true,
    super.automaticallyImplyLeading,
    double super.elevation = 0,
  }) : super(
    title: Text(title),
  );
}
