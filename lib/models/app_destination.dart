// lib/models/app_destination.dart

import 'package:flutter/material.dart';

// A model to represent a navigation destination.
// This now includes the `selectedIcon` property from your updated code.
class AppDestination {
  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon; // New property for the filled/selected icon
  final Widget page;

  const AppDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}