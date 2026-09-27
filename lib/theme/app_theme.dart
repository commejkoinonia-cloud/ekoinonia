import 'package:flutter/material.dart';

/// Charte graphique de l'application ECODIM.
///
/// Toutes les couleurs de l'app doivent venir d'ici, pour que changer
/// une couleur globalement se fasse en un seul endroit, jamais en dur
/// dans les écrans.
class AppColors {
  // Couleur dominante : bleu (barre de navigation, boutons principaux)
  static const Color bleu = Color(0xFF1B4F9C);

  // Base claire
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color grisClair = Color(0xFFF2F4F7);

  // Accent positif (présence validée, succès, badges "actif")
  static const Color vertBleute = Color(0xFF16A085);

  // Accent secondaire (badges de fonction, éléments à distinguer)
  static const Color violetBleute = Color(0xFF4A4E9C);

  // Alertes / absences / suppressions
  static const Color rougeAlerte = Color(0xFFD32F2F);

  // Texte courant
  static const Color texte = Color(0xFF333333);
  static const Color texteClair = Color(0xFF8A8A8A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.grisClair,

      // Palette de couleurs générée à partir de notre bleu de marque.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bleu,
        primary: AppColors.bleu,
        secondary: AppColors.violetBleute,
        tertiary: AppColors.vertBleute,
        error: AppColors.rougeAlerte,
        surface: AppColors.blanc,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bleu,
        foregroundColor: AppColors.blanc,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bleu,
          foregroundColor: AppColors.blanc,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanc,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),

      cardTheme: CardThemeData(
        color: AppColors.blanc,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blanc,
        selectedItemColor: AppColors.bleu,
        unselectedItemColor: AppColors.texteClair,
        type: BottomNavigationBarType.fixed,
      ),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.texte),
        bodySmall: TextStyle(color: AppColors.texteClair),
      ),
    );
  }
}