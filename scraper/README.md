# ============================================================
# AFRICAN CHINA BUSINESS CHALLENGE 2026
# SYSTÈME DE SCRAPING + IA
# ============================================================

## 📁 Structure

```
scraper/
├── main.py                 # Point d'entrée principal
├── config.py               # Configuration (Supabase, sites, etc.)
├── requirements.txt        # Dépendances Python
├── scrapers/
│   ├── __init__.py
│   ├── base_scraper.py     # Classe de base
│   ├── jumia_scraper.py    # Scraper Jumia (multi-pays)
│   ├── expat_dakar.py      # Scraper Expat-Dakar
│   ├── coinafrique.py      # Scraper CoinAfrique
│   └── generic_scraper.py  # Scraper générique (Google Shopping)
├── ai/
│   ├── __init__.py
│   ├── embeddings.py       # Génération d'embeddings
│   └── clustering.py       # Regroupement produits similaires
└── utils/
    ├── __init__.py
    ├── database.py         # Connexion Supabase
    └── helpers.py          # Fonctions utilitaires
```

## 🚀 Installation

```bash
cd scraper
pip install -r requirements.txt
python main.py
```

## ⏰ Automatisation (Cron Job)

```bash
# Exécuter tous les jours à 6h du matin
0 6 * * * cd /path/to/scraper && python main.py >> /var/log/scraper.log 2>&1
```

## 🔧 Configuration

Modifiez `config.py` avec vos credentials Supabase.
