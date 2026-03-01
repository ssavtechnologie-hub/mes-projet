import 'package:equatable/equatable.dart';

/// Modèle Score de Matching
class ScoreMatching extends Equatable {
  final String id;
  final String membreId;
  final String fournisseurId;
  final String? produitFournisseurId;
  final double scoreCompatibilite;
  final double? scoreBudget;
  final double? scoreCategorie;
  final double? scoreExperience;
  final double? scoreLocalisation;
  final List<String> raisonsMatch;
  final int priorite;
  final String statut;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final String? fournisseurNom;
  final double? fournisseurFiabilite;
  final String? produitNom;
  final double? produitPrix;

  const ScoreMatching({
    required this.id,
    required this.membreId,
    required this.fournisseurId,
    this.produitFournisseurId,
    required this.scoreCompatibilite,
    this.scoreBudget,
    this.scoreCategorie,
    this.scoreExperience,
    this.scoreLocalisation,
    this.raisonsMatch = const [],
    this.priorite = 0,
    this.statut = 'nouveau',
    required this.createdAt,
    required this.updatedAt,
    this.fournisseurNom,
    this.fournisseurFiabilite,
    this.produitNom,
    this.produitPrix,
  });

  factory ScoreMatching.fromJson(Map<String, dynamic> json) {
    return ScoreMatching(
      id: json['id'] as String,
      membreId: json['membre_id'] as String,
      fournisseurId: json['fournisseur_id'] as String,
      produitFournisseurId: json['produit_fournisseur_id'] as String?,
      scoreCompatibilite: (json['score_compatibilite'] as num).toDouble(),
      scoreBudget: (json['score_budget'] as num?)?.toDouble(),
      scoreCategorie: (json['score_categorie'] as num?)?.toDouble(),
      scoreExperience: (json['score_experience'] as num?)?.toDouble(),
      scoreLocalisation: (json['score_localisation'] as num?)?.toDouble(),
      raisonsMatch: (json['raisons_match'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      priorite: json['priorite'] as int? ?? 0,
      statut: json['statut'] as String? ?? 'nouveau',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      fournisseurNom: json['fournisseurs_chine']?['nom'] as String?,
      fournisseurFiabilite: (json['fournisseurs_chine']?['score_fiabilite'] as num?)?.toDouble(),
      produitNom: json['produits_fournisseurs']?['nom'] as String?,
      produitPrix: (json['produits_fournisseurs']?['prix_usine'] as num?)?.toDouble(),
    );
  }

  int get scorePercentage => (scoreCompatibilite * 100).round();

  String get statutLabel {
    switch (statut) {
      case 'nouveau':
        return 'Nouveau';
      case 'vu':
        return 'Vu';
      case 'contacte':
        return 'Contacté';
      case 'en_cours':
        return 'En cours';
      case 'conclu':
        return 'Conclu';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  String get qualiteMatch {
    if (scoreCompatibilite >= 0.9) return 'Excellent';
    if (scoreCompatibilite >= 0.8) return 'Très bon';
    if (scoreCompatibilite >= 0.7) return 'Bon';
    if (scoreCompatibilite >= 0.6) return 'Correct';
    return 'Acceptable';
  }

  @override
  List<Object?> get props => [
        id,
        membreId,
        fournisseurId,
        produitFournisseurId,
        scoreCompatibilite,
        scoreBudget,
        scoreCategorie,
        scoreExperience,
        scoreLocalisation,
        raisonsMatch,
        priorite,
        statut,
        createdAt,
        updatedAt,
        fournisseurNom,
        fournisseurFiabilite,
        produitNom,
        produitPrix,
      ];
}
