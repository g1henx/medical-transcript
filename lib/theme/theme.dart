import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1F1F1F), // Dark grey
  hintColor: const Color(0xFFBB86FC), // Almost black
  scaffoldBackgroundColor: const Color(0xFF121212),
  canvasColor: const Color(0xFF1E1E1E),
  cardColor: const Color(0xFF2C2C2C),
  dividerColor: const Color(0xFFBDBDBD),
  focusColor: const Color(0xFF1A73E8), // Blue
  hoverColor: const Color(0xFF1C1C1E),
  splashColor: const Color(0xFFBB86FC),
  highlightColor: const Color(0xFFBB86FC),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFBB86FC), // Purple
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white, fontSize: 57.0),
    displayMedium: TextStyle(color: Colors.white, fontSize: 45.0),
    displaySmall: TextStyle(color: Colors.white, fontSize: 36.0),
    headlineLarge: TextStyle(color: Colors.white, fontSize: 32.0),
    headlineMedium: TextStyle(color: Colors.white, fontSize: 28.0),
    headlineSmall: TextStyle(color: Colors.white, fontSize: 24.0),
    titleLarge: TextStyle(color: Colors.white, fontSize: 22.0),
    titleMedium: TextStyle(color: Colors.white, fontSize: 16.0),
    titleSmall: TextStyle(color: Colors.white, fontSize: 14.0),
    bodyLarge: TextStyle(color: Colors.white, fontSize: 16.0),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14.0),
    bodySmall: TextStyle(color: Colors.white70, fontSize: 12.0),
    labelLarge: TextStyle(color: Colors.white, fontSize: 14.0),
    labelMedium: TextStyle(color: Colors.white70, fontSize: 12.0),
    labelSmall: TextStyle(color: Colors.white70, fontSize: 11.0),
  ),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF1F1F1F),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFBB86FC), // Purple
    onPrimary: Color(0xFF000000), // Black
    primaryContainer: Color(0xFF3700B3), // Dark Purple
    onPrimaryContainer: Color(0xFFFFFFFF), // White
    primaryFixed: Color(0xFFBB86FC),
    primaryFixedDim: Color(0xFF6200EE),
    onPrimaryFixed: Color(0xFF000000),
    onPrimaryFixedVariant: Color(0xFF3700B3),
    secondary: Color(0xFF03DAC6), // Teal
    onSecondary: Color(0xFF000000), // Black
    secondaryContainer: Color(0xFF018786), // Dark Teal
    onSecondaryContainer: Color(0xFFFFFFFF), // White
    secondaryFixed: Color(0xFF03DAC6),
    secondaryFixedDim: Color(0xFF018786),
    onSecondaryFixed: Color(0xFF000000),
    onSecondaryFixedVariant: Color(0xFF018786),
    tertiary: Color(0xFFCF6679), // Red
    onTertiary: Color(0xFF000000), // Black
    tertiaryContainer: Color(0xFFB00020), // Dark Red
    onTertiaryContainer: Color(0xFFFFFFFF), // White
    tertiaryFixed: Color(0xFFCF6679),
    tertiaryFixedDim: Color(0xFFB00020),
    onTertiaryFixed: Color(0xFF000000),
    onTertiaryFixedVariant: Color(0xFFB00020),
    error: Color(0xFFCF6679), // Error Red
    onError: Color(0xFF000000), // Black
    errorContainer: Color(0xFFB00020), // Dark Error Red
    onErrorContainer: Color(0xFFFFFFFF), // White
    surface: Color(0xFF121212), // Almost Black
    onSurface: Color(0xFFFFFFFF), // White
    surfaceDim: Color(0xFF1E1E1E),
    surfaceBright: Color(0xFF2C2C2C),
    surfaceContainerLowest: Color(0xFF121212),
    surfaceContainerLow: Color(0xFF1E1E1E),
    surfaceContainer: Color(0xFF2C2C2C),
    surfaceContainerHigh: Color(0xFF3E3E3E),
    surfaceContainerHighest: Color(0xFF4F4F4F),
    onSurfaceVariant: Color(0xFFBDBDBD), // Grey
    outline: Color(0xFFBDBDBD), // Grey
    outlineVariant: Color(0xFF8A8A8A),
    shadow: Color(0xFF000000), // Black
    scrim: Color(0xFF000000), // Black
    inverseSurface: Color(0xFFFFFFFF), // White
    onInverseSurface: Color(0xFF000000), // Black
    inversePrimary: Color(0xFFBB86FC), // Purple
    surfaceTint: Color(0xFFBB86FC), // Purple
  )
);