# 🌍 African China Business Challenge 2026

## Infrastructure d'Intelligence Commerciale Afrique-Chine

Ce projet fournit une solution complète pour connecter les importateurs africains aux fournisseurs chinois, avec analyse de marges automatisée et matching intelligent.

---

## 📁 Structure du Projet

```
acbc_project/
├── supabase/                    # Backend Supabase
│   ├── migrations/              # Schéma SQL
│   │   ├── 001_initial_schema.sql
│   │   └── 003_triggers_functions.sql
│   ├── policies/                # Row Level Security
│   │   └── 002_row_level_security.sql
│   └── functions/               # Edge Functions
│       ├── calculate-margin/
│       ├── smart-matching/
│       ├── send-whatsapp/
│       └── generate-report/
│
└── flutter_app/                 # Application Mobile Flutter
    ├── lib/
    │   ├── core/                # Configuration & Thème
    │   ├── models/              # Modèles de données
    │   ├── services/            # Services Supabase
    │   └── features/            # Écrans par fonctionnalité
    └── pubspec.yaml
```

---

## 🚀 Installation

### 1. Backend Supabase

#### Créer un projet Supabase
1. Allez sur [supabase.com](https://supabase.com)
2. Créez un nouveau projet
3. Notez votre `Project URL` et `anon key`

#### Exécuter les migrations SQL
Dans l'éditeur SQL de Supabase, exécutez dans l'ordre :

```bash
# 1. Schéma initial (tables, index)
supabase/migrations/001_initial_schema.sql

# 2. Policies RLS (sécurité)
supabase/policies/002_row_level_security.sql

# 3. Triggers et fonctions
supabase/migrations/003_triggers_functions.sql
```

#### Déployer les Edge Functions
```bash
# Installer Supabase CLI
npm install -g supabase

# Login
supabase login

# Lier au projet
supabase link --project-ref YOUR_PROJECT_ID

# Déployer les fonctions
supabase functions deploy calculate-margin
supabase functions deploy smart-matching
supabase functions deploy send-whatsapp
supabase functions deploy generate-report
```

#### Variables d'environnement Edge Functions
Configurez dans Supabase Dashboard > Edge Functions > Secrets :
```
WHATSAPP_API_URL=https://graph.facebook.com/v17.0
WHATSAPP_TOKEN=your_whatsapp_token
WHATSAPP_PHONE_ID=your_phone_id
```

---

### 2. Application Flutter

#### Prérequis
- Flutter SDK 3.0+
- Dart 3.0+

#### Configuration
1. Modifiez `lib/core/config/supabase_config.dart` :
```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';
}
```

#### Installation des dépendances
```bash
cd flutter_app
flutter pub get
```

#### Lancer l'application
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

---

## 📊 Tables de la Base de Données

| Table | Description |
|-------|-------------|
| `pays_africains` | Référentiel des pays africains |
| `categories_produits` | Catégories de produits |
| `produits_afrique` | Produits sur les marchés africains |
| `fournisseurs_chine` | Fournisseurs chinois vérifiés |
| `produits_fournisseurs` | Catalogue produits des fournisseurs |
| `membres_club` | Importateurs inscrits |
| `analyses_marges` | Calculs de rentabilité |
| `scores_matching` | Résultats du matching IA |
| `mises_en_relation` | Connexions membre-fournisseur |
| `notifications` | Notifications utilisateurs |
| `rapports_hebdomadaires` | Rapports pour membres premium |
| `transactions` | Historique des commandes |

---

## ⚡ Edge Functions

### `calculate-margin`
Calcul automatique des marges avec coûts de transport, douane et logistique.

**Request:**
```json
{
  "produit_afrique_id": "uuid",
  "produit_fournisseur_id": "uuid",
  "quantite": 100,
  "cout_transport": 500,
  "cout_logistique": 200
}
```

### `smart-matching`
Algorithme de matching intelligent membre ↔ fournisseur.

**Request:**
```json
{
  "membre_id": "uuid",
  "limit": 20,
  "seuil_minimum": 0.5
}
```

### `generate-report`
Génération de rapports hebdomadaires pour membres premium.

### `send-whatsapp`
Envoi de notifications via WhatsApp Business API.

---

## 🔐 Sécurité (RLS)

- **Membres** : Accès limité à leur propre profil
- **Produits** : Lecture pour tous les membres authentifiés
- **Fournisseurs** : Seuls les fournisseurs vérifiés sont visibles
- **Analyses** : Membres gratuits = 7 jours, Premium = illimité
- **Admin** : Accès complet via le rôle admin

---

## 📱 Fonctionnalités Flutter

- ✅ Authentification (login/register)
- ✅ Dashboard avec statistiques
- ✅ Liste des produits africains
- ✅ Catalogue fournisseurs
- ✅ Matching intelligent
- ✅ Analyse de marges
- ✅ Notifications
- ✅ Rapports hebdomadaires
- ✅ Profil utilisateur

---

## 🎨 Design System

- **Couleur principale** : `#1E3A5F` (Bleu marine)
- **Couleur secondaire** : `#D4A84B` (Or)
- **Accent** : `#2ECC71` (Vert)
- **Police** : Poppins

---

## 📈 Roadmap

| Phase | Durée | Objectif |
|-------|-------|----------|
| 1 | Mois 1 | MVP + Base de données |
| 2 | Mois 2 | Embeddings + Clustering |
| 3 | Mois 3 | Automatisation marges |
| 4 | Mois 4 | WhatsApp Business API |
| 5 | Mois 5 | Dashboard admin |
| 6 | Mois 6 | Performance + Sécurité |

---

## 💰 Modèle Économique

- **Commission fournisseur** : 3-7%
- **Mise en relation qualifiée** : Frais fixes
- **Abonnement Premium** : Rapports hebdomadaires + accès complet

---

## 🛠️ Support

Pour toute question, contactez l'équipe ACBC.

---

**© 2026 African China Business Challenge**
