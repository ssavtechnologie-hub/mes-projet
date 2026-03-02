# ============================================================
# SCRAPER COINAFRIQUE
# ============================================================

from bs4 import BeautifulSoup
from typing import List, Dict, Optional
import re

from .base_scraper import BaseScraper
from utils.helpers import clean_price, clean_text, convert_to_usd

class CoinAfriqueScraper(BaseScraper):
    """Scraper pour CoinAfrique (petites annonces)"""
    
    def get_category_urls(self) -> List[str]:
        """URLs des catégories CoinAfrique"""
        categories = [
            '/categorie/telephones-tablettes',
            '/categorie/electronique',
            '/categorie/electromenager',
            '/categorie/vetements-mode',
            '/categorie/vehicules',
            '/categorie/maison-meubles',
            '/categorie/beaute-bien-etre'
        ]
        return [f"{self.base_url}{cat}" for cat in categories]
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser la liste des annonces CoinAfrique"""
        products = []
        
        # Sélecteur CoinAfrique
        articles = soup.select('.ad-item, .listing-item, article[class*="ad"]')
        
        for article in articles:
            try:
                product = self._parse_coinafrique_article(article)
                if product:
                    products.append(product)
            except Exception:
                continue
        
        return products
    
    def _parse_coinafrique_article(self, article) -> Optional[Dict]:
        """Parser une annonce CoinAfrique"""
        # Titre
        title_elem = article.select_one('.ad-title, h2, h3, [class*="title"]')
        if not title_elem:
            return None
        
        name = clean_text(title_elem.get_text())
        if not name:
            return None
        
        # Prix
        price_elem = article.select_one('.ad-price, .price, [class*="price"]')
        if not price_elem:
            return None
        
        price = clean_price(price_elem.get_text())
        if not price or price <= 0:
            return None
        
        price_usd = convert_to_usd(price, self.currency)
        
        # Image
        img_elem = article.select_one('img')
        image_url = img_elem.get('data-src') or img_elem.get('src') if img_elem else None
        
        # Lien
        link_elem = article.select_one('a[href]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('/'):
                product_url = f"{self.base_url}{href}"
            elif href.startswith('http'):
                product_url = href
        
        # Localisation
        location_elem = article.select_one('.ad-location, .location, [class*="location"]')
        location = clean_text(location_elem.get_text()) if location_elem else None
        
        return {
            'nom': name,
            'prix_moyen': price_usd,
            'prix_min': price_usd * 0.85,
            'prix_max': price_usd * 1.15,
            'devise': 'USD',
            'prix_origine': price,
            'image_url': image_url,
            'product_url': product_url,
            'localisation': location,
            'engagement_marche': 'moyen'
        }
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Page suivante CoinAfrique"""
        next_link = soup.select_one('a[rel="next"], a.next, [class*="next"] a')
        if next_link:
            href = next_link.get('href', '')
            if href.startswith('/'):
                return f"{self.base_url}{href}"
            elif href.startswith('http'):
                return href
        return None
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        return None
