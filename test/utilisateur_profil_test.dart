import 'package:ekoinonia/models/utilisateur_profil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UtilisateurProfil.depuisFirestore', () {
    test('lit tous les champs du document utilisateurs/{uid}', () {
      final profil = UtilisateurProfil.depuisFirestore('uid-1', {
        'nom': 'Koffi',
        'prenom': 'Aline',
        'classeId': '6B',
        'fonctions': ['moniteur', 'charge_materiel'],
        'imageUrl': 'https://exemple.com/aline.png',
        'actif': true,
      });

      expect(profil.uid, 'uid-1');
      expect(profil.nom, 'Koffi');
      expect(profil.prenom, 'Aline');
      expect(profil.classeId, '6B');
      expect(profil.fonctions, ['moniteur', 'charge_materiel']);
      expect(profil.imageUrl, 'https://exemple.com/aline.png');
      expect(profil.actif, isTrue);
      expect(profil.nomComplet, 'Aline Koffi');
    });

    test('met des valeurs par défaut si des champs manquent', () {
      final profil = UtilisateurProfil.depuisFirestore('uid-2', {});

      expect(profil.nom, isEmpty);
      expect(profil.prenom, isEmpty);
      expect(profil.classeId, isEmpty);
      expect(profil.fonctions, isEmpty);
      expect(profil.imageUrl, isNull);
      expect(profil.actif, isTrue);
    });
  });

  group('Droits par fonction', () {
    UtilisateurProfil avecFonctions(List<String> fonctions) =>
        UtilisateurProfil.depuisFirestore('uid', {'fonctions': fonctions});

    test('responsable et responsable_adjoint sont administrateurs', () {
      expect(avecFonctions(['responsable']).estAdmin, isTrue);
      expect(avecFonctions(['responsable_adjoint']).estAdmin, isTrue);
      expect(avecFonctions(['moniteur']).estAdmin, isFalse);
    });

    test('caissiere et caissiere_adjoint sont caissières', () {
      expect(avecFonctions(['caissiere']).estCaissiere, isTrue);
      expect(avecFonctions(['caissiere_adjoint']).estCaissiere, isTrue);
      expect(avecFonctions(['moniteur']).estCaissiere, isFalse);
    });

    test('un adjoint hérite du droit de son rôle principal', () {
      final adjoint = avecFonctions(['charge_materiel_adjoint']);

      expect(adjoint.estChargeMateriel, isTrue);
      expect(adjoint.estChargeCommunication, isFalse);
      expect(adjoint.estChargeDiscipline, isFalse);
    });

    test('aFonction teste une valeur précise de la liste', () {
      final profil = avecFonctions(['moniteur']);

      expect(profil.aFonction('moniteur'), isTrue);
      expect(profil.aFonction('responsable'), isFalse);
    });
  });

  group('badges', () {
    test('traduit les fonctions en libellés lisibles', () {
      final profil = UtilisateurProfil.depuisFirestore('uid', {
        'fonctions': ['responsable', 'charge_materiel_adjoint'],
      });

      expect(profil.badges, ['Responsable', 'Adjoint Matériel']);
    });

    test('conserve la valeur brute si la fonction est inconnue', () {
      final profil =
          UtilisateurProfil.depuisFirestore('uid', {'fonctions': ['mystere']});

      expect(profil.badges, ['mystere']);
    });

    test('est vide quand la personne n\'a aucune fonction', () {
      final profil = UtilisateurProfil.depuisFirestore('uid', {});

      expect(profil.badges, isEmpty);
    });
  });
}
