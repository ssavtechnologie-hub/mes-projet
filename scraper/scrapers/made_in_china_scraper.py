# ============================================================
# SCRAPER MADE IN CHINA - Fournisseurs vérifiés
# ============================================================

import re
import logging
from bs4 import BeautifulSoup
from typing import List, Dict, Optional

from .base_scraper import BaseScraper
from utils.helpers import clean_price, clean_text
from utils.proxy_manager import proxy_manager
from utils.anti_detection import anti_detection

logger = logging.getLogger(__name__)

class MadeInChinaScraper(BaseScraper):
    """
    Scraper pour Made-in-China.com (B2B, fournisseurs vérifiés)
    """
    
    def __init__(self, site_config: Dict = None):
        default_config = {
            "name": "Made-in-China",
            "base_url": "https://www.made-in-china.com",
            "country": "Chine",
            "country_code": "CHN",
            "currency": "USD",
        }
        super().__init__(site_config or default_config)
        self.request_count = 0
    
    def get_headers(self) -> Dict:
        """Headers Made-in-China"""
        headers = anti_detection.get_random_headers(for_china=True)
        headers["Referer"] = "https://www.made-in-china.com/"
        return headers
    
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Récupérer avec proxy"""
        for attempt in range(self.max_retries):
            proxy = proxy_manager.get_proxy()
            
            try:
                self.request_count += 1
                anti_detection.human_like_delay()
                
                proxies = proxy.dict_format if proxy else None
                
                response = self.session.get(
                    url,
                    headers=self.get_headers(),
                    proxies=proxies,
                    timeout=self.timeout
                )
                
                if response.status_code == 200:
                    if proxy:
                        proxy_manager.report_success(proxy)
                    return BeautifulSoup(response.content, 'lxml')
                
                if proxy:
                    proxy_manager.report_failure(proxy)
                    
            except Exception as e:
                logger.warning(f"[Made-in-China] Erreur: {e}")
                if proxy:
                    proxy_manager.report_failure(proxy)
        
        return None
    
    def get_category_urls(self) -> List[str]:
        """URLs de recherche"""
        categories = [
            "electronics", "machinery", "electrical-equipment",
            "lights-lighting", "home-appliances", "furniture",
            "textiles", "fashion-accessories", "beauty-care",
            "automotive-parts", "construction-materials", "packaging"
        ]
        
        urls = []
        for cat in categories:
            urls.append(f"{self.base_url}/productdirectory/{cat}/")
        return urls
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser les produits"""
        products = []
        
        articles = soup.select('.product-item, .sr-item, [class*="product-card"]')
        
        for article in articles:
            try:
                product = self._parse_product(article)
                if product:
                    products.append(product)
            except:
                continue
        
        return products
    
    def _parse_product(self, article) -> Optional[Dict]:
        """Parser un produit"""
        # Titre
        title_elem = article.select_one('h2 a, h3 a, .product-name a, [class*="title"]')
        if not title_elem:
            return None
        
        name = clean_text(title_elem.get_text())
        if not name:
            return None
        
        # Prix
        price_elem = article.select_one('.price, [class*="price"]')
        price = None
        if price_elem:
            price = clean_price(price_elem.get_text())
        
        if not price:
            # Prix par défaut si non trouvé
            price = 0
        
        # MOQ
        moq = 1
        moq_elem = article.select_one('[class*="moq"], [class*="min-order"]')
        if moq_elem:
            moq_match = re.search(r'(\d+)', moq_elem.get_text())
            if moq_match:
                moq = int(moq_match.group(1))
        
        # Fournisseur
        supplier_elem = article.select_one('.company-name a, [class*="supplier"]')
        supplier_name = clean_text(supplier_elem.get_text()) if supplier_elem else None
        
        # Vérifié
        verified = bool(article.select_one('[class*="verified"], [class*="gold"], .audited'))
        
        # Image
        img_elem = article.select_one('img')
        image_url = img_elem.get('data-src') or img_elem.get('src') if img_elem else None
        
        # Lien
        link_elem = title_elem if title_elem.name == 'a' else article.select_one('a[href]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('/'):
                product_url = self.base_url + href
            elif href.startswith('http'):
                product_url = href
        
        return {
            'type': 'fournisseur',
            'nom_produit': name,
            'prix_usine': price if price > 0 else None,
            'prix_min': price if price > 0 else None,
            'prix_max': price if price > 0 else None,
            'devise': 'USD',
            'moq': moq,
            'nom_fournisseur': supplier_name,
            'verifie': verified,
            'image_url': image_url,
            'product_url': product_url,
            'source': 'Made-in-China',
            'score_fiabilite': 0.85 if verified else 0.6
        }
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Page suivante"""
        next_link = soup.select_one('a.next, [class*="pagination"] a[rel="next"]')
        if next_link:
            href = next_link.get('href', '')
            if href.startswith('/'):
                return self.base_url + href
            return href
        return None
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        return None
