# ============================================================
# SCRAPER GÉNÉRIQUE (pour tout site e-commerce)
# ============================================================

from bs4 import BeautifulSoup
from typing import List, Dict, Optional
import re

from .base_scraper import BaseScraper
from utils.helpers import clean_price, clean_text, convert_to_usd

class GenericScraper(BaseScraper):
    """
    Scraper générique intelligent qui s'adapte à tout site
    Utilise des heuristiques pour détecter les produits
    """
    
    def get_category_urls(self) -> List[str]:
        """Retourne l'URL de base + pages communes"""
        common_paths = [
            '/products', '/produits', '/shop', '/boutique',
            '/catalog', '/catalogue', '/all', '/tout',
            '/electronics', '/electronique', '/phones', '/telephones'
        ]
        urls = [self.base_url]
        for path in common_paths:
            urls.append(f"{self.base_url}{path}")
        return urls[:5]  # Limiter à 5 URLs
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser intelligent de produits"""
        products = []
        
        # Stratégie 1: Chercher des articles/items de produits
        selectors = [
            'article[class*="product"]',
            'div[class*="product"]',
            'li[class*="product"]',
            '.product-item',
            '.product-card',
            '.item-card',
            '.listing-item',
            '[data-product]',
            '.card',
        ]
        
        articles = []
        for selector in selectors:
            articles = soup.select(selector)
            if articles:
                break
        
        # Stratégie 2: Chercher des conteneurs avec prix
        if not articles:
            # Trouver tous les éléments avec un prix
            price_elements = soup.find_all(text=re.compile(r'[\$€£₣]?\s*\d{1,3}[,.\s]?\d{3}'))
            for price_el in price_elements[:50]:  # Limiter
                parent = price_el.find_parent(['article', 'div', 'li'])
                if parent and parent not in articles:
                    articles.append(parent)
        
        for article in articles[:100]:  # Limiter à 100 produits
            try:
                product = self._parse_generic_article(article)
                if product:
                    products.append(product)
            except Exception:
                continue
        
        return products
    
    def _parse_generic_article(self, article) -> Optional[Dict]:
        """Parser un article de manière générique"""
        # Chercher le titre
        name = None
        title_selectors = ['h1', 'h2', 'h3', 'h4', '.title', '.name', '[class*="title"]', '[class*="name"]', 'a']
        for sel in title_selectors:
            elem = article.select_one(sel)
            if elem:
                text = clean_text(elem.get_text())
                if text and len(text) > 3 and len(text) < 200:
                    name = text
                    break
        
        if not name:
            return None
        
        # Chercher le prix
        price = None
        price_selectors = ['.price', '[class*="price"]', '[class*="prix"]', '.amount', '[class*="cost"]']
        for sel in price_selectors:
            elem = article.select_one(sel)
            if elem:
                price = clean_price(elem.get_text())
                if price and price > 0:
                    break
        
        # Essayer de trouver un prix dans le texte
        if not price:
            text = article.get_text()
            numbers = re.findall(r'[\$€£]?\s*(\d{1,3}[,.\s]?\d{3}(?:[,.\s]?\d{2})?)', text)
            for num in numbers:
                p = clean_price(num)
                if p and 1 < p < 1000000:
                    price = p
                    break
        
        if not price or price <= 0:
            return None
        
        price_usd = convert_to_usd(price, self.currency)
        
        # Image
        img_elem = article.select_one('img')
        image_url = None
        if img_elem:
            image_url = img_elem.get('data-src') or img_elem.get('src') or img_elem.get('data-lazy-src')
        
        # Lien
        link_elem = article.select_one('a[href]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('/'):
                product_url = f"{self.base_url}{href}"
            elif href.startswith('http'):
                product_url = href
        
        return {
            'nom': name,
            'prix_moyen': price_usd,
            'prix_min': price_usd * 0.85,
            'prix_max': price_usd * 1.15,
            'devise': 'USD',
            'prix_origine': price,
            'image_url': image_url,
            'product_url': product_url,
            'engagement_marche': 'moyen'
        }
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Trouver la page suivante"""
        next_selectors = [
            'a[rel="next"]',
            'a.next',
            '.pagination a.next',
            '[class*="next"] a',
            'a[aria-label*="next"]',
            'a[aria-label*="suivant"]'
        ]
        
        for sel in next_selectors:
            link = soup.select_one(sel)
            if link:
                href = link.get('href', '')
                if href.startswith('/'):
                    return f"{self.base_url}{href}"
                elif href.startswith('http'):
                    return href
        
        return None
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        return None
