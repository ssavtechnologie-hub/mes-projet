# ============================================================
# CONFIGURATION DU SCRAPER - VERSION COMPLÈTE AFRIQUE
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
# SITES À SCRAPER - TOUTE L'AFRIQUE
# ============================================================
SITES_CONFIG = {
    # ============================================================
    # AFRIQUE DE L'OUEST
    # ============================================================
    "jumia_sn": {
        "name": "Jumia Sénégal",
        "base_url": "https://www.jumia.sn",
        "country": "Sénégal",
        "country_code": "SEN",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "jumia_ci": {
        "name": "Jumia Côte d'Ivoire",
        "base_url": "https://www.jumia.ci",
        "country": "Côte d'Ivoire",
        "country_code": "CIV",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "jumia_ng": {
        "name": "Jumia Nigeria",
        "base_url": "https://www.jumia.com.ng",
        "country": "Nigeria",
        "country_code": "NGA",
        "currency": "NGN",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "jumia_gh": {
        "name": "Jumia Ghana",
        "base_url": "https://www.jumia.com.gh",
        "country": "Ghana",
        "country_code": "GHA",
        "currency": "GHS",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "expat_dakar": {
        "name": "Expat-Dakar",
        "base_url": "https://www.expat-dakar.com",
        "country": "Sénégal",
        "country_code": "SEN",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_sn": {
        "name": "CoinAfrique Sénégal",
        "base_url": "https://sn.coinafrique.com",
        "country": "Sénégal",
        "country_code": "SEN",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_ci": {
        "name": "CoinAfrique Côte d'Ivoire",
        "base_url": "https://ci.coinafrique.com",
        "country": "Côte d'Ivoire",
        "country_code": "CIV",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_ml": {
        "name": "CoinAfrique Mali",
        "base_url": "https://ml.coinafrique.com",
        "country": "Mali",
        "country_code": "MLI",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_bf": {
        "name": "CoinAfrique Burkina Faso",
        "base_url": "https://bf.coinafrique.com",
        "country": "Burkina Faso",
        "country_code": "BFA",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_bj": {
        "name": "CoinAfrique Bénin",
        "base_url": "https://bj.coinafrique.com",
        "country": "Bénin",
        "country_code": "BEN",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_tg": {
        "name": "CoinAfrique Togo",
        "base_url": "https://tg.coinafrique.com",
        "country": "Togo",
        "country_code": "TGO",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_ne": {
        "name": "CoinAfrique Niger",
        "base_url": "https://ne.coinafrique.com",
        "country": "Niger",
        "country_code": "NER",
        "currency": "XOF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    "coinafrique_gn": {
        "name": "CoinAfrique Guinée",
        "base_url": "https://gn.coinafrique.com",
        "country": "Guinée",
        "country_code": "GIN",
        "currency": "GNF",
        "region": "Afrique de l'Ouest",
        "enabled": True
    },
    
    # ============================================================
    # AFRIQUE CENTRALE
    # ============================================================
    "jumia_cm": {
        "name": "Jumia Cameroun",
        "base_url": "https://www.jumia.cm",
        "country": "Cameroun",
        "country_code": "CMR",
        "currency": "XAF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "coinafrique_cm": {
        "name": "CoinAfrique Cameroun",
        "base_url": "https://cm.coinafrique.com",
        "country": "Cameroun",
        "country_code": "CMR",
        "currency": "XAF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "coinafrique_cd": {
        "name": "CoinAfrique RD Congo",
        "base_url": "https://cd.coinafrique.com",
        "country": "RD Congo",
        "country_code": "COD",
        "currency": "CDF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "coinafrique_cg": {
        "name": "CoinAfrique Congo-Brazzaville",
        "base_url": "https://cg.coinafrique.com",
        "country": "Congo-Brazzaville",
        "country_code": "COG",
        "currency": "XAF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "coinafrique_ga": {
        "name": "CoinAfrique Gabon",
        "base_url": "https://ga.coinafrique.com",
        "country": "Gabon",
        "country_code": "GAB",
        "currency": "XAF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "coinafrique_td": {
        "name": "CoinAfrique Tchad",
        "base_url": "https://td.coinafrique.com",
        "country": "Tchad",
        "country_code": "TCD",
        "currency": "XAF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "coinafrique_cf": {
        "name": "CoinAfrique Centrafrique",
        "base_url": "https://cf.coinafrique.com",
        "country": "Centrafrique",
        "country_code": "CAF",
        "currency": "XAF",
        "region": "Afrique Centrale",
        "enabled": True
    },
    "vendito_cd": {
        "name": "Vendito RD Congo",
        "base_url": "https://www.vendito.cd",
        "country": "RD Congo",
        "country_code": "COD",
        "currency": "USD",
        "region": "Afrique Centrale",
        "enabled": True
    },
    
    # ============================================================
    # AFRIQUE DE L'EST
    # ============================================================
    "jumia_ke": {
        "name": "Jumia Kenya",
        "base_url": "https://www.jumia.co.ke",
        "country": "Kenya",
        "country_code": "KEN",
        "currency": "KES",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jumia_ug": {
        "name": "Jumia Uganda",
        "base_url": "https://www.jumia.ug",
        "country": "Ouganda",
        "country_code": "UGA",
        "currency": "UGX",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jumia_tz": {
        "name": "Jumia Tanzania",
        "base_url": "https://www.jumia.co.tz",
        "country": "Tanzanie",
        "country_code": "TZA",
        "currency": "TZS",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jumia_rw": {
        "name": "Jumia Rwanda",
        "base_url": "https://www.jumia.rw",
        "country": "Rwanda",
        "country_code": "RWA",
        "currency": "RWF",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jiji_ke": {
        "name": "Jiji Kenya",
        "base_url": "https://jiji.co.ke",
        "country": "Kenya",
        "country_code": "KEN",
        "currency": "KES",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jiji_ug": {
        "name": "Jiji Uganda",
        "base_url": "https://jiji.ug",
        "country": "Ouganda",
        "country_code": "UGA",
        "currency": "UGX",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jiji_tz": {
        "name": "Jiji Tanzania",
        "base_url": "https://jiji.co.tz",
        "country": "Tanzanie",
        "country_code": "TZA",
        "currency": "TZS",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    "jiji_et": {
        "name": "Jiji Ethiopia",
        "base_url": "https://jiji.et",
        "country": "Éthiopie",
        "country_code": "ETH",
        "currency": "ETB",
        "region": "Afrique de l'Est",
        "enabled": True
    },
    
    # ============================================================
    # AFRIQUE DU NORD
    # ============================================================
    "jumia_ma": {
        "name": "Jumia Maroc",
        "base_url": "https://www.jumia.ma",
        "country": "Maroc",
        "country_code": "MAR",
        "currency": "MAD",
        "region": "Afrique du Nord",
        "enabled": True
    },
    "jumia_eg": {
        "name": "Jumia Égypte",
        "base_url": "https://www.jumia.com.eg",
        "country": "Égypte",
        "country_code": "EGY",
        "currency": "EGP",
        "region": "Afrique du Nord",
        "enabled": True
    },
    "jumia_tn": {
        "name": "Jumia Tunisie",
        "base_url": "https://www.jumia.com.tn",
        "country": "Tunisie",
        "country_code": "TUN",
        "currency": "TND",
        "region": "Afrique du Nord",
        "enabled": True
    },
    "jumia_dz": {
        "name": "Jumia Algérie",
        "base_url": "https://www.jumia.dz",
        "country": "Algérie",
        "country_code": "DZA",
        "currency": "DZD",
        "region": "Afrique du Nord",
        "enabled": True
    },
    "avito_ma": {
        "name": "Avito Maroc",
        "base_url": "https://www.avito.ma",
        "country": "Maroc",
        "country_code": "MAR",
        "currency": "MAD",
        "region": "Afrique du Nord",
        "enabled": True
    },
    "tayara_tn": {
        "name": "Tayara Tunisie",
        "base_url": "https://www.tayara.tn",
        "country": "Tunisie",
        "country_code": "TUN",
        "currency": "TND",
        "region": "Afrique du Nord",
        "enabled": True
    },
    "ouedkniss_dz": {
        "name": "Ouedkniss Algérie",
        "base_url": "https://www.ouedkniss.com",
        "country": "Algérie",
        "country_code": "DZA",
        "currency": "DZD",
        "region": "Afrique du Nord",
        "enabled": True
    },
    
    # ============================================================
    # AFRIQUE AUSTRALE
    # ============================================================
    "jumia_za": {
        "name": "Jumia South Africa",
        "base_url": "https://www.jumia.co.za",
        "country": "Afrique du Sud",
        "country_code": "ZAF",
        "currency": "ZAR",
        "region": "Afrique Australe",
        "enabled": True
    },
    "gumtree_za": {
        "name": "Gumtree South Africa",
        "base_url": "https://www.gumtree.co.za",
        "country": "Afrique du Sud",
        "country_code": "ZAF",
        "currency": "ZAR",
        "region": "Afrique Australe",
        "enabled": True
    },
    "olx_za": {
        "name": "OLX South Africa",
        "base_url": "https://www.olx.co.za",
        "country": "Afrique du Sud",
        "country_code": "ZAF",
        "currency": "ZAR",
        "region": "Afrique Australe",
        "enabled": True
    },
    "facebook_mz": {
        "name": "Marketplace Mozambique",
        "base_url": "https://www.facebook.com/marketplace/maputo",
        "country": "Mozambique",
        "country_code": "MOZ",
        "currency": "MZN",
        "region": "Afrique Australe",
        "enabled": False  # Nécessite auth Facebook
    },
}

# ============================================================
# CATÉGORIES À SCRAPER
# ============================================================
CATEGORIES = [
    {
        "name": "Électronique",
        "keywords": ["smartphone", "téléphone", "phone", "ordinateur", "laptop", "tablette", "tv", "télévision", "écran", "computer"],
        "jumia_path": "/telephones-tablettes/",
        "jiji_path": "/phones-tablets/",
        "priority": 1
    },
    {
        "name": "Électroménager",
        "keywords": ["ventilateur", "climatiseur", "réfrigérateur", "frigo", "machine à laver", "micro-onde", "cuisinière", "fan", "fridge", "washing"],
        "jumia_path": "/maison-electromenager/",
        "jiji_path": "/electronics/",
        "priority": 1
    },
    {
        "name": "Mode & Vêtements",
        "keywords": ["chemise", "pantalon", "robe", "chaussures", "sac", "montre", "shirt", "shoes", "dress", "bag"],
        "jumia_path": "/mode/",
        "jiji_path": "/fashion/",
        "priority": 2
    },
    {
        "name": "Beauté & Cosmétiques",
        "keywords": ["parfum", "crème", "maquillage", "cheveux", "soin", "perfume", "cream", "makeup", "beauty"],
        "jumia_path": "/beaute-hygiene/",
        "jiji_path": "/health-beauty/",
        "priority": 2
    },
    {
        "name": "Maison & Mobilier",
        "keywords": ["meuble", "canapé", "lit", "table", "chaise", "décoration", "furniture", "sofa", "bed", "chair"],
        "jumia_path": "/maison-bureau/",
        "jiji_path": "/home-garden/",
        "priority": 3
    },
    {
        "name": "Automobile",
        "keywords": ["pneu", "batterie", "huile", "accessoire auto", "pièce détachée", "tire", "car", "motor", "vehicle"],
        "jumia_path": "/automobile/",
        "jiji_path": "/vehicles/",
        "priority": 2
    },
    {
        "name": "Sport & Loisirs",
        "keywords": ["ballon", "vélo", "fitness", "sport", "camping", "ball", "bicycle", "gym"],
        "jumia_path": "/sports-loisirs/",
        "jiji_path": "/sports-arts/",
        "priority": 3
    },
    {
        "name": "Informatique",
        "keywords": ["imprimante", "clavier", "souris", "écran", "printer", "keyboard", "mouse", "monitor", "computer"],
        "jumia_path": "/informatique/",
        "jiji_path": "/computers/",
        "priority": 2
    },
    {
        "name": "Alimentation",
        "keywords": ["riz", "huile", "sucre", "farine", "conserve", "rice", "oil", "sugar", "food"],
        "jumia_path": "/epicerie/",
        "jiji_path": "/",
        "priority": 3
    },
    {
        "name": "Bébé & Enfant",
        "keywords": ["couche", "biberon", "poussette", "jouet", "bébé", "baby", "diaper", "toy", "stroller"],
        "jumia_path": "/bebe-puericulture/",
        "jiji_path": "/babies-kids/",
        "priority": 3
    },
    {
        "name": "Matériaux Construction",
        "keywords": ["ciment", "fer", "brique", "peinture", "cement", "iron", "brick", "paint", "building"],
        "jumia_path": "/bricolage/",
        "jiji_path": "/building/",
        "priority": 2
    },
    {
        "name": "Agriculture",
        "keywords": ["tracteur", "semence", "engrais", "irrigation", "tractor", "seed", "fertilizer", "farm"],
        "jumia_path": "/jardin/",
        "jiji_path": "/agriculture/",
        "priority": 3
    },
    {
        "name": "Énergie Solaire",
        "keywords": ["panneau solaire", "batterie solaire", "onduleur", "solar panel", "inverter", "solar"],
        "jumia_path": "/energie-solaire/",
        "jiji_path": "/",
        "priority": 2
    }
]

# ============================================================
# PARAMÈTRES SCRAPING
# ============================================================
SCRAPING_CONFIG = {
    "max_pages_per_category": 15,      # Plus de pages
    "max_products_per_site": 1000,     # Plus de produits par site
    "delay_between_requests": 1.5,     # Secondes
    "timeout": 45,
    "retry_count": 3,
    "user_agent_rotation": True,
    "concurrent_scrapers": 3           # Scrapers en parallèle
}

# ============================================================
# PARAMÈTRES IA
# ============================================================
AI_CONFIG = {
    "embedding_model": "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2",
    "embedding_dimension": 384,
    "similarity_threshold": 0.82,      # Seuil pour regroupement
    "clustering_min_samples": 2,
    "batch_size": 100
}

# ============================================================
# TAUX DE CHANGE (vers USD) - Mise à jour régulière recommandée
# ============================================================
EXCHANGE_RATES = {
    # Afrique de l'Ouest (FCFA BCEAO)
    "XOF": 0.0016,
    # Afrique Centrale (FCFA BEAC)
    "XAF": 0.0016,
    # Nigeria
    "NGN": 0.00065,
    # Ghana
    "GHS": 0.078,
    # Guinée
    "GNF": 0.00012,
    # Kenya
    "KES": 0.0064,
    # Ouganda
    "UGX": 0.00027,
    # Tanzanie
    "TZS": 0.00039,
    # Rwanda
    "RWF": 0.00077,
    # Éthiopie
    "ETB": 0.018,
    # RD Congo
    "CDF": 0.00036,
    # Maroc
    "MAD": 0.099,
    # Égypte
    "EGP": 0.032,
    # Tunisie
    "TND": 0.32,
    # Algérie
    "DZD": 0.0074,
    # Afrique du Sud
    "ZAR": 0.053,
    # Mozambique
    "MZN": 0.016,
    # USD
    "USD": 1.0
}

# ============================================================
# PAYS ADDITIONNELS POUR LA BASE DE DONNÉES
# ============================================================
ADDITIONAL_COUNTRIES = [
    {"nom": "Ouganda", "code_iso": "UGA", "devise": "UGX", "taux_douane_moyen": 18.00},
    {"nom": "Tanzanie", "code_iso": "TZA", "devise": "TZS", "taux_douane_moyen": 18.00},
    {"nom": "Rwanda", "code_iso": "RWA", "devise": "RWF", "taux_douane_moyen": 15.00},
    {"nom": "Congo-Brazzaville", "code_iso": "COG", "devise": "XAF", "taux_douane_moyen": 20.00},
    {"nom": "Gabon", "code_iso": "GAB", "devise": "XAF", "taux_douane_moyen": 20.00},
    {"nom": "Tchad", "code_iso": "TCD", "devise": "XAF", "taux_douane_moyen": 20.00},
    {"nom": "Centrafrique", "code_iso": "CAF", "devise": "XAF", "taux_douane_moyen": 20.00},
    {"nom": "Mozambique", "code_iso": "MOZ", "devise": "MZN", "taux_douane_moyen": 15.00},
]
