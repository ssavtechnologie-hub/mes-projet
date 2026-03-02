# ============================================================
# SCRAPER ALIEXPRESS - Fournisseurs B2C
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

class AliExpressScraper(BaseScraper):
    """
    Scraper pour AliExpress (B2C, petits volumes)
    """
    
    def __init__(self, site_config: Dict = None):
        default_config = {
            "name": "AliExpress",
            "base_url": "https://www.aliexpress.com",
            "country": "Chine",
            "country_code": "CHN",
            "currency": "USD",
        }
        super().__init__(site_config or default_config)
        self.request_count = 0
    
    def get_headers(self) -> Dict:
        """Headers AliExpress"""
        headers = anti_detection.get_random_headers(for_china=True)
        headers.update({
            "Referer": "https://www.aliexpress.com/",
            "Origin": "https://www.aliexpress.com",
        })
        return headers
    
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Récupérer avec proxy"""
        for attempt in range(self.max_retries):
            proxy = proxy_manager.get_proxy()
            
            try:
                self.request_count += 1
                
                if anti_detection.should_pause(self.request_count):
                    anti_detection.long_pause()
                
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
                logger.warning(f"[AliExpress] Erreur: {e}")
                if proxy:
                    proxy_manager.report_failure(proxy)
        
        return None
    
    def get_category_urls(self) -> List[str]:
        """URLs de recherche"""
        terms = [
            "smartphone", "laptop", "tablet", "headphones",
            "smart watch", "led tv", "projector",
            "fan", "air conditioner", "refrigerator",
            "solar panel", "power bank", "charger",
            "dress", "shoes", "bag", "jewelry"
        ]
        
        urls = []
        for term in terms:
            urls.append(f"{self.base_url}/wholesale?SearchText={term.replace(' ', '+')}")
        return urls
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser les produits AliExpress"""
        products = []
        
        articles = soup.select('[class*="product-item"], [class*="list-item"], .search-item-card')
        
        if not articles:
            articles = soup.select('[data-product-id], [class*="card"]')
        
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
        title_elem = article.select_one('h1, h2, h3, [class*="title"] a, a[title]')
        if not title_elem:
            return None
        
        name = clean_text(title_elem.get_text() or title_elem.get('title', ''))
        if not name:
            return None
        
        # Prix
        price_elem = article.select_one('[class*="price"], .price')
        if not price_elem:
            return None
        
        price = clean_price(price_elem.get_text())
        if not price:
            return None
        
        # Évaluations
        rating = None
        rating_elem = article.select_one('[class*="rating"], [class*="star"]')
        if rating_elem:
            rating_match = re.search(r'([\d.]+)', rating_elem.get_text())
            if rating_match:
                rating = float(rating_match.group(1))
        
        # Commandes
        orders = 0
        orders_elem = article.select_one('[class*="order"], [class*="sold"]')
        if orders_elem:
            orders_match = re.search(r'([\d,]+)', orders_elem.get_text())
            if orders_match:
                orders = int(orders_match.group(1).replace(',', ''))
        
        # Nom vendeur
        seller_elem = article.select_one('[class*="store"], [class*="seller"]')
        seller_name = clean_text(seller_elem.get_text()) if seller_elem else None
        
        # Image
        img_elem = article.select_one('img')
        image_url = img_elem.get('data-src') or img_elem.get('src') if img_elem else None
        
        # Lien
        link_elem = article.select_one('a[href*="/item/"]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('//'):
                product_url = 'https:' + href
            elif href.startswith('/'):
                product_url = self.base_url + href
            else:
                product_url = href
        
        # Score fiabilité basé sur les commandes
        if orders > 1000:
            score = 0.9
        elif orders > 100:
            score = 0.7
        elif orders > 10:
            score = 0.5
        else:
            score = 0.3
        
        return {
            'type': 'fournisseur',
            'nom_produit': name,
            'prix_usine': price,
            'prix_min': price,
            'prix_max': price,
            'devise': 'USD',
            'moq': 1,
            'nom_fournisseur': seller_name,
            'rating': rating,
            'nombre_commandes': orders,
            'image_url': image_url,
            'product_url': product_url,
            'source': 'AliExpress',
            'score_fiabilite': score
        }
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Page suivante"""
        if 'page=' in current_url:
            match = re.search(r'page=(\d+)', current_url)
            if match:
                page = int(match.group(1))
                return re.sub(r'page=\d+', f'page={page + 1}', current_url)
        return current_url + '&page=2'
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        return None
