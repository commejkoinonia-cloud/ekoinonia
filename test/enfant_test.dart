import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekoinonia/models/enfant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timestampTest = Timestamp.fromDate(DateTime(2016, 3, 14));

  group('Enfant.depuisFirestore - types corrects', () {
    final donnees = <String, dynamic>{
      'nom': 'Kouassi',
      'prenom': 'Yao',
      'sexe': 'Masculin',
      'classeId': '6B',
      'nomTuteur': 'Kouassi Paul',
      'telephoneTuteur': '+228 90 00 00 00',
      'adresse': 'Lomé',
      'actif': true,
      'imageUrl': 'https://exemple.com/yao.png',
      'dateNaissance': timestampTest,
      'dateInscription': Timestamp.fromDate(DateTime(2026, 1, 10)),
      'aDejaParticipeOEN': true,
      'anneeParticipationOEN': 2024,
      'moyenneDevoirs': 14.5,
      'nombreDevoirsNotes': 3,
    };

    test('lit tous les champs', () {
      final enfant = Enfant.depuisFirestore('id-1', donnees);

      expect(enfant.id, 'id-1');
      expect(enfant.nomComplet, 'Yao Kouassi');
      expect(enfant.sexe, 'Masculin');
      expect(enfant.classeId, '6B');
      expect(enfant.telephoneTuteur, '+228 90 00 00 00');
      expect(enfant.imageUrl, 'https://exemple.com/yao.png');
      expect(enfant.dateNaissance, DateTime(2016, 3, 14));
      expect(enfant.dateInscription, DateTime(2026, 1, 10));
      expect(enfant.aDejaParticipeOEN, isTrue);
      expect(enfant.anneeParticipationOEN, 2024);
      expect(enfant.moyenneDevoirs, 14.5);
      expect(enfant.nombreDevoirsNotes, 3);
    });

    test('un document minimal donne des valeurs par défaut', () {
      final enfant = Enfant.depuisFirestore('id-2', {});

      expect(enfant.nom, isEmpty);
      expect(enfant.actif, isTrue);
      expect(enfant.aDejaParticipeOEN, isFalse);
      expect(enfant.dateNaissance, isNull);
      expect(enfant.anneeParticipationOEN, isNull);
      expect(enfant.moyenneDevoirs, isNull);
      expect(enfant.age, isNull);
    });
  });

  group('Enfant.depuisFirestore - types incorrects (ne doit plus planter)', () {
    test('un Timestamp sur un champ int devient null', () {
      final enfant = Enfant.depuisFirestore('id-3', {
        'nom': 'Koffi',
        'anneeParticipationOEN': timestampTest,
        'nombreDevoirsNotes': timestampTest,
      });

      expect(enfant.anneeParticipationOEN, isNull);
      expect(enfant.nombreDevoirsNotes, isNull);
      expect(enfant.nom, 'Koffi');
    });

    test('un Timestamp sur un champ texte devient vide', () {
      final enfant = Enfant.depuisFirestore('id-4', {
        'nom': timestampTest,
        'prenom': 42,
        'imageUrl': timestampTest,
      });

      expect(enfant.nom, isEmpty);
      expect(enfant.prenom, isEmpty);
      expect(enfant.imageUrl, isNull);
    });

    test('un Timestamp sur un champ bool prend la valeur par défaut', () {
      final enfant = Enfant.depuisFirestore('id-5', {
        'actif': timestampTest,
        'aDejaParticipeOEN': 'oui',
      });

      expect(enfant.actif, isTrue);
      expect(enfant.aDejaParticipeOEN, isFalse);
    });

    test('une date stockée en millisecondes ou en texte est comprise', () {
      final enfant = Enfant.depuisFirestore('id-6', {
        'dateNaissance': DateTime(2016, 3, 14).millisecondsSinceEpoch,
        'dateInscription': '2026-01-10',
      });

      expect(enfant.dateNaissance, DateTime(2016, 3, 14));
      expect(enfant.dateInscription, DateTime(2026, 1, 10));
    });

    test('une moyenne stockée en texte est comprise, virgule comprise', () {
      expect(
        Enfant.depuisFirestore('id-7', {'moyenneDevoirs': '14,5'}).moyenneDevoirs,
        14.5,
      );
      expect(
        Enfant.depuisFirestore('id-8', {'moyenneDevoirs': 14}).moyenneDevoirs,
        14.0,
      );
      expect(
        Enfant.depuisFirestore('id-9', {'moyenneDevoirs': timestampTest}).moyenneDevoirs,
        isNull,
      );
    });
  });

  group('age', () {
    test('compte les années révolues', () {
      final enfant = Enfant.depuisFirestore('id-10', {
        'dateNaissance': DateTime(DateTime.now().year - 10, 1, 1),
      });

      expect(enfant.age, 10);
    });

    test('retire un an si l’anniversaire n’est pas encore passé', () {
      final demain = DateTime.now().add(const Duration(days: 1));
      final enfant = Enfant.depuisFirestore('id-11', {
        'dateNaissance': DateTime(DateTime.now().year - 10, demain.month, demain.day),
      });

      expect(enfant.age, 9);
    });
  });

  group('versFirestore', () {
    test('écrit les dates en Timestamp et omet les champs vides', () {
      final enfant = Enfant(
        id: 'id-12',
        nom: 'Kouassi',
        prenom: 'Yao',
        sexe: 'Masculin',
        classeId: '6B',
        nomTuteur: '',
        telephoneTuteur: '',
        adresse: '',
        actif: true,
        dateNaissance: DateTime(2016, 3, 14),
        anneeParticipationOEN: 2024,
      );

      final donnees = enfant.versFirestore();

      expect(donnees['dateNaissance'], isA<Timestamp>());
      expect(donnees['anneeParticipationOEN'], 2024);
      expect(donnees.containsKey('dateInscription'), isFalse);
      expect(donnees.containsKey('imageUrl'), isFalse);
      expect(donnees['nomTuteur'], isEmpty);
    });

    test('aller-retour : le modèle relit ce qu’il a écrit', () {
      final source = Enfant(
        id: 'id-13',
        nom: 'Koffi',
        prenom: 'Aline',
        sexe: 'Féminin',
        classeId: '5A',
        nomTuteur: 'Koffi Paul',
        telephoneTuteur: '+228 91 11 11 11',
        adresse: 'Aného',
        actif: true,
        dateNaissance: DateTime(2015, 9, 2),
        aDejaParticipeOEN: true,
        anneeParticipationOEN: 2025,
      );

      final relu = Enfant.depuisFirestore('id-13', source.versFirestore());

      expect(relu.nomComplet, 'Aline Koffi');
      expect(relu.dateNaissance, DateTime(2015, 9, 2));
      expect(relu.anneeParticipationOEN, 2025);
      expect(relu.aDejaParticipeOEN, isTrue);
    });
  });
}
