import 'package:flutter/material.dart';
import 'package:omeamobile/utils/app_colors.dart';

class AppStyles {
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle forgotPasswordStyle = TextStyle(
    color: AppColors.primaryColor,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle termsAndPrivacyStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: 13,
    color: AppColors.linkColor, // Utilise la nouvelle couleur linkColor
    decoration: TextDecoration.underline,
  );

  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 16.0,
      horizontal: 16.0,
    ),
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    minimumSize: const Size(double.infinity, 50), // Full width
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    minimumSize: const Size(double.infinity, 50), // Full width
  );
}
