import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/utilisateur_profil.dart';
import '../../theme/app_theme.dart';
import '../enfants/enfant_detail_screen.dart';

/// Ouvre la caméra et attend de détecter un QR code généré par l'app
/// (format "enfant:{id}", et plus tard "moniteur:{id}"). On ignore
/// silencieusement tout QR qui n'a pas ce format : ce n'est pas à nous
/// de scanner n'importe quel code (site web, etc.).
class QrScannerScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const QrScannerScreen({super.key, required this.profil});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controleur = MobileScannerController();

  // Empêche de traiter 10 fois le même QR pendant la fraction de seconde
  // où la caméra continue de le voir après la première détection.
  bool _dejaTraite = false;

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  void _surDetection(BarcodeCapture capture) {
    if (_dejaTraite) return;

    final valeurBrute = capture.barcodes.firstOrNull?.rawValue;
    if (valeurBrute == null) return;

    if (valeurBrute.startsWith('enfant:')) {
      final enfantId = valeurBrute.substring('enfant:'.length);
      setState(() => _dejaTraite = true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EnfantDetailScreen(enfantId: enfantId, profil: widget.profil),
        ),
      );
      return;
    }

    // Préparé pour plus tard, quand le QR moniteur existera :
    // if (valeurBrute.startsWith('moniteur:')) { ... }

    _afficherCodeNonReconnu();
  }

  void _afficherCodeNonReconnu() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ce QR code n'est pas reconnu par l'application.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controleur.toggleTorch(),
            tooltip: 'Lampe torche',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controleur,
            onDetect: _surDetection,
          ),
          // Cadre visuel simple pour indiquer où placer le QR code.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.vertBleute, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Placez le QR code de l\'enfant dans le cadre',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blanc),
              ),
            ),
          ),
        ],
      ),
    );
  }
}