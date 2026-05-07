import 'package:flutter/material.dart';


class AppColors {
  
  static const Color primary = Color(0xFF6C5CE7);   
  static const Color primaryDark = Color(0xFF5B4FCF);
  static const Color secondary = Color(0xFFFFD93D);   
  static const Color accent = Color(0xFFFF6B6B);       


  static const Color background = Color(0xFFF8F4FF);   
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFEFEAFF);

  
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  
  static const Color tileBg = Color(0xFFFFE3A3);       
  static const Color tileBgSelected = Color(0xFFFF9F43); 
  static const Color tileText = Color(0xFF2D3436);
  static const Color tileBorder = Color(0xFFE17055);

  
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);

  
  static const Color buttonPrimary = Color(0xFF6C5CE7);
  static const Color buttonGold = Color(0xFFFFD93D);
  static const Color buttonShadow = Color(0xFF4834D4);

  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD93D), Color(0xFFFF9F43)],
  );
}



