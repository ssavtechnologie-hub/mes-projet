# ============================================================
# FONCTIONS UTILITAIRES
# ============================================================

import re
import hashlib
from typing import Optional
from config import EXCHANGE_RATES

def clean_price(price_str: str) -> Optional[float]:
    """
    Nettoyer et convertir une chaîne de prix en float
    Ex: "150 000 FCFA" -> 150000.0
    """
    if not price_str:
        return None
    
    # Supprimer tout sauf les chiffres, points et virgules
    cleaned = re.sub(r'[^\d.,]', '', price_str)
    
    # Gérer les formats européens (1.000,00) vs américains (1,000.00)
    if ',' in cleaned and '.' in cleaned:
        if cleaned.rfind(',') > cleaned.rfind('.'):
            # Format européen
            cleaned = cleaned.replace('.', '').replace(',', '.')
        else:
            # Format américain
            cleaned = cleaned.replace(',', '')
    elif ',' in cleaned:
        # Peut être décimal ou milliers
        if len(cleaned.split(',')[-1]) <= 2:
            cleaned = cleaned.replace(',', '.')
        else:
            cleaned = cleaned.replace(',', '')
    
    try:
        return float(cleaned)
    except ValueError:
        return None


def convert_to_usd(price: float, currency: str) -> float:
    """Convertir un prix en USD"""
    rate = EXCHANGE_RATES.get(currency, 1.0)
    return round(price * rate, 2)


def clean_text(text: str) -> str:
    """Nettoyer un texte (supprimer espaces multiples, etc.)"""
    if not text:
        return ""
    # Supprimer les espaces multiples
    text = re.sub(r'\s+', ' ', text)
    # Supprimer les espaces en début/fin
    return text.strip()


def generate_product_hash(name: str, price: float, country: str) -> str:
    """Générer un hash unique pour un produit (éviter les doublons)"""
    unique_str = f"{name.lower()}_{price}_{country.lower()}"
    return hashlib.md5(unique_str.encode()).hexdigest()


def extract_numbers(text: str) -> list:
    """Extraire tous les nombres d'un texte"""
    return [float(x) for x in re.findall(r'\d+\.?\d*', text)]


def categorize_product(name: str, description: str = "") -> str:
    """
    Catégoriser automatiquement un produit basé sur son nom/description
    """
    text = f"{name} {description}".lower()
    
    categories_keywords = {
        "Électronique": ["smartphone", "téléphone", "phone", "iphone", "samsung", "laptop", 
                         "ordinateur", "pc", "tablette", "tablet", "tv", "télévision", "écran"],
        "Électroménager": ["ventilateur", "climatiseur", "clim", "frigo", "réfrigérateur", 
                          "machine à laver", "lave-linge", "micro-onde", "cuisinière", "four"],
        "Mode & Vêtements": ["chemise", "pantalon", "robe", "jupe", "chaussure", "basket",
                            "sac", "montre", "bijou", "vêtement", "t-shirt", "jean"],
        "Beauté & Cosmétiques": ["parfum", "crème", "maquillage", "rouge à lèvres", "mascara",
                                 "shampooing", "soin", "beauté", "cosmétique"],
        "Maison & Mobilier": ["meuble", "canapé", "sofa", "lit", "matelas", "table", "chaise",
                             "armoire", "décoration", "rideau", "tapis"],
        "Automobile": ["pneu", "batterie", "huile", "moteur", "voiture", "auto", "moto",
                      "pièce détachée", "accessoire auto"],
        "Sport & Loisirs": ["ballon", "vélo", "fitness", "sport", "gym", "football",
                           "basketball", "camping", "randonnée"]
    }
    
    for category, keywords in categories_keywords.items():
        for keyword in keywords:
            if keyword in text:
                return category
    
    return "Autres"


def format_price_display(price: float, currency: str = "USD") -> str:
    """Formater un prix pour l'affichage"""
    if currency == "USD":
        return f"${price:,.2f}"
    elif currency in ["XOF", "XAF"]:
        return f"{price:,.0f} FCFA"
    else:
        return f"{price:,.2f} {currency}"
