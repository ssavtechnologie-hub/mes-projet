# ============================================================
# SCRAPER JUMIA (Multi-pays)
# ============================================================

from bs4 import BeautifulSoup
from typing import List, Dict, Optional
import re

from .base_scraper import BaseScraper
from utils.helpers import clean_price, clean_text, convert_to_usd
from config import CATEGORIES

class JumiaScraper(BaseScraper):
    """Scraper pour Jumia (tous pays africains)"""
    
    def get_category_urls(self) -> List[str]:
        """Générer les URLs des catégories Jumia"""
        urls = []
        for cat in CATEGORIES:
            path = cat.get('jumia_path', '')
            if path:
                urls.append(f"{self.base_url}{path}")
        return urls
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser la liste des produits Jumia"""
        products = []
        
        # Sélecteur pour les articles Jumia
        articles = soup.select('article.prd._fb.col.c-prd')
        
        if not articles:
            # Essayer un autre sélecteur
            articles = soup.select('article[class*="prd"]')
        
        if not articles:
            # Dernier recours
            articles = soup.select('.sku.-gallery')
        
        for article in articles:
            try:
                product = self._parse_jumia_article(article)
                if product:
                    products.append(product)
            except Exception as e:
                continue
        
        return products
    
    def _parse_jumia_article(self, article) -> Optional[Dict]:
        """Parser un article Jumia"""
        # Nom du produit
        name_elem = article.select_one('.name, .info h3, [class*="name"]')
        if not name_elem:
            return None
        
        name = clean_text(name_elem.get_text())
        if not name:
            return None
        
        # Prix actuel
        price_elem = article.select_one('.prc, .price, [class*="price"]')
        if not price_elem:
            return None
        
        price_text = price_elem.get_text()
        price = clean_price(price_text)
        if not price or price <= 0:
            return None
        
        # Prix en USD
        price_usd = convert_to_usd(price, self.currency)
        
        # Ancien prix (si promotion)
        old_price = None
        old_price_elem = article.select_one('.old, [class*="old"]')
        if old_price_elem:
            old_price = clean_price(old_price_elem.get_text())
        
        # Image
        img_elem = article.select_one('img')
        image_url = img_elem.get('data-src') or img_elem.get('src') if img_elem else None
        
        # Lien du produit
        link_elem = article.select_one('a[href]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('/'):
                product_url = f"{self.base_url}{href}"
            elif href.startswith('http'):
                product_url = href
        
        # Note/Rating
        rating = None
        rating_elem = article.select_one('.stars._s, [class*="rating"]')
        if rating_elem:
            rating_text = rating_elem.get_text()
            rating_match = re.search(r'(\d+\.?\d*)', rating_text)
            if rating_match:
                rating = float(rating_match.group(1))
        
        return {
            'nom': name,
            'prix_moyen': price_usd,
            'prix_min': price_usd * 0.9,  # Estimation -10%
            'prix_max': price_usd * 1.1,  # Estimation +10%
            'devise': 'USD',
            'prix_origine': price,
            'ancien_prix': old_price,
            'image_url': image_url,
            'product_url': product_url,
            'rating': rating,
            'engagement_marche': self._estimate_engagement(rating)
        }
    
    def _estimate_engagement(self, rating: Optional[float]) -> str:
        """Estimer l'engagement marché basé sur le rating"""
        if rating is None:
            return 'moyen'
        if rating >= 4.0:
            return 'fort'
        elif rating >= 3.0:
            return 'moyen'
        else:
            return 'faible'
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Trouver la page suivante Jumia"""
        # Chercher le lien "page suivante"
        next_link = soup.select_one('a[aria-label="Page suivante"], a.pg, a[class*="next"]')
        
        if next_link:
            href = next_link.get('href', '')
            if href:
                if href.startswith('/'):
                    return f"{self.base_url}{href}"
                elif href.startswith('http'):
                    return href
        
        # Essayer d'incrémenter le numéro de page dans l'URL
        if '?page=' in current_url:
            match = re.search(r'\?page=(\d+)', current_url)
            if match:
                current_page = int(match.group(1))
                return re.sub(r'\?page=\d+', f'?page={current_page + 1}', current_url)
        elif '?' in current_url:
            return current_url + '&page=2'
        else:
            return current_url + '?page=2'
        
        return None
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        """Parser les détails d'un produit (page individuelle)"""
        # Pour une utilisation future si besoin de plus de détails
        return None
