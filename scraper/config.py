# ============================================================
# CONFIGURATION DU SCRAPER
# ============================================================

import os
from dotenv import load_dotenv

load_dotenv()

# ============================================================
# SUPABASE
# ============================================================
SUPABASE_URL = os.getenv("SUPABASE_URL", "https://YOUR_PROJECT.supabase.co")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "YOUR_ANON_KEY")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY", "YOUR_SERVICE_KEY")

# ============================================================
# SITES À SCRAPER
# ============================================================
SITES_CONFIG = {
    "jumia_sn": {
        "name": "Jumia Sénégal",
        "base_url": "https://www.jumia.sn",
        "country": "Sénégal",
        "country_code": "SEN",
        "currency": "XOF",
        "enabled": True
    },
    "jumia_ci": {
        "name": "Jumia Côte d'Ivoire",
        "base_url": "https://www.jumia.ci",
        "country": "Côte d'Ivoire",
        "country_code": "CIV",
        "currency": "XOF",
        "enabled": True
    },
    "jumia_cm": {
        "name": "Jumia Cameroun",
        "base_url": "https://www.jumia.cm",
        "country": "Cameroun",
        "country_code": "CMR",
        "currency": "XAF",
        "enabled": True
    },
    "jumia_ng": {
        "name": "Jumia Nigeria",
        "base_url": "https://www.jumia.com.ng",
        "country": "Nigeria",
        "country_code": "NGA",
        "currency": "NGN",
        "enabled": True
    },
    "jumia_ke": {
        "name": "Jumia Kenya",
        "base_url": "https://www.jumia.co.ke",
        "country": "Kenya",
        "country_code": "KEN",
        "currency": "KES",
        "enabled": True
    },
    "jumia_ma": {
        "name": "Jumia Maroc",
        "base_url": "https://www.jumia.ma",
        "country": "Maroc",
        "country_code": "MAR",
        "currency": "MAD",
        "enabled": True
    },
    "jumia_eg": {
        "name": "Jumia Égypte",
        "base_url": "https://www.jumia.com.eg",
        "country": "Égypte",
        "country_code": "EGY",
        "currency": "EGP",
        "enabled": True
    },
    "jumia_gh": {
        "name": "Jumia Ghana",
        "base_url": "https://www.jumia.com.gh",
        "country": "Ghana",
        "country_code": "GHA",
        "currency": "GHS",
        "enabled": True
    },
    "expat_dakar": {
        "name": "Expat-Dakar",
        "base_url": "https://www.expat-dakar.com",
        "country": "Sénégal",
        "country_code": "SEN",
        "currency": "XOF",
        "enabled": True
    },
    "coinafrique_sn": {
        "name": "CoinAfrique Sénégal",
        "base_url": "https://sn.coinafrique.com",
        "country": "Sénégal",
        "country_code": "SEN",
        "currency": "XOF",
        "enabled": True
    },
    "coinafrique_ci": {
        "name": "CoinAfrique Côte d'Ivoire",
        "base_url": "https://ci.coinafrique.com",
        "country": "Côte d'Ivoire",
        "country_code": "CIV",
        "currency": "XOF",
        "enabled": True
    }
}

# ============================================================
# CATÉGORIES À SCRAPER
# ============================================================
CATEGORIES = [
    {
        "name": "Électronique",
        "keywords": ["smartphone", "téléphone", "ordinateur", "laptop", "tablette", "tv", "télévision"],
        "jumia_path": "/telephones-tablettes/",
        "priority": 1
    },
    {
        "name": "Électroménager",
        "keywords": ["ventilateur", "climatiseur", "réfrigérateur", "frigo", "machine à laver", "micro-onde"],
        "jumia_path": "/maison-electromenager/",
        "priority": 1
    },
    {
        "name": "Mode & Vêtements",
        "keywords": ["chemise", "pantalon", "robe", "chaussures", "sac", "montre"],
        "jumia_path": "/mode/",
        "priority": 2
    },
    {
        "name": "Beauté & Cosmétiques",
        "keywords": ["parfum", "crème", "maquillage", "cheveux", "soin"],
        "jumia_path": "/beaute-hygiene/",
        "priority": 2
    },
    {
        "name": "Maison & Mobilier",
        "keywords": ["meuble", "canapé", "lit", "table", "chaise", "décoration"],
        "jumia_path": "/maison-bureau/",
        "priority": 3
    },
    {
        "name": "Automobile",
        "keywords": ["pneu", "batterie", "huile", "accessoire auto", "pièce détachée"],
        "jumia_path": "/automobile/",
        "priority": 3
    },
    {
        "name": "Sport & Loisirs",
        "keywords": ["ballon", "vélo", "fitness", "sport", "camping"],
        "jumia_path": "/sports-loisirs/",
        "priority": 3
    }
]

# ============================================================
# PARAMÈTRES SCRAPING
# ============================================================
SCRAPING_CONFIG = {
    "max_pages_per_category": 10,
    "max_products_per_site": 500,
    "delay_between_requests": 2,  # secondes
    "timeout": 30,
    "retry_count": 3,
    "user_agent_rotation": True
}

# ============================================================
# PARAMÈTRES IA
# ============================================================
AI_CONFIG = {
    "embedding_model": "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2",
    "embedding_dimension": 384,
    "similarity_threshold": 0.85,  # Pour regrouper les produits similaires
    "clustering_min_samples": 2,
    "batch_size": 100
}

# ============================================================
# TAUX DE CHANGE (USD)
# ============================================================
EXCHANGE_RATES = {
    "XOF": 0.0016,   # 1 XOF = 0.0016 USD
    "XAF": 0.0016,   # 1 XAF = 0.0016 USD
    "NGN": 0.00065,  # 1 NGN = 0.00065 USD
    "KES": 0.0065,   # 1 KES = 0.0065 USD
    "GHS": 0.082,    # 1 GHS = 0.082 USD
    "MAD": 0.099,    # 1 MAD = 0.099 USD
    "EGP": 0.032,    # 1 EGP = 0.032 USD
    "ZAR": 0.053,    # 1 ZAR = 0.053 USD
    "USD": 1.0
}
