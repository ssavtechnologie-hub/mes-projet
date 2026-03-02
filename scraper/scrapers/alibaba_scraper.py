# ============================================================
# SCRAPER ALIBABA - Fournisseurs B2B
# ============================================================

import re
import json
import logging
from bs4 import BeautifulSoup
from typing import List, Dict, Optional
import requests

from .base_scraper import BaseScraper
from utils.helpers import clean_price, clean_text
from utils.proxy_manager import proxy_manager
from utils.anti_detection import anti_detection
from config import CATEGORIES

logger = logging.getLogger(__name__)

class AlibabaScraper(BaseScraper):
    """
    Scraper pour Alibaba.com (Fournisseurs B2B chinois)
    Utilise rotation de proxies et anti-détection
    """
    
    def __init__(self, site_config: Dict = None):
        default_config = {
            "name": "Alibaba",
            "base_url": "https://www.alibaba.com",
            "country": "Chine",
            "country_code": "CHN",
            "currency": "USD",
        }
        super().__init__(site_config or default_config)
        
        self.search_url = "https://www.alibaba.com/trade/search"
        self.request_count = 0
    
    def get_headers(self) -> Dict:
        """Headers spécifiques Alibaba avec anti-détection"""
        return anti_detection.get_alibaba_headers()
    
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Récupérer une page avec proxy et anti-détection"""
        for attempt in range(self.max_retries):
            proxy = proxy_manager.get_proxy()
            
            try:
                self.request_count += 1
                
                # Pause longue périodique
                if anti_detection.should_pause(self.request_count):
                    anti_detection.long_pause()
                
                logger.info(f"[Alibaba] Requête #{self.request_count} - {url[:80]}...")
                
                # Délai humain
                anti_detection.human_like_delay()
                
                proxies = proxy.dict_format if proxy else None
                
                response = self.session.get(
                    url,
                    headers=self.get_headers(),
                    proxies=proxies,
                    timeout=self.timeout,
                    cookies=anti_detection.get_cookies_template("alibaba")
                )
                
                if response.status_code == 200:
                    if proxy:
                        proxy_manager.report_success(proxy)
                    return BeautifulSoup(response.content, 'lxml')
                
                elif response.status_code == 403:
                    logger.warning(f"[Alibaba] 403 Forbidden - Proxy bloqué")
                    if proxy:
                        proxy_manager.report_failure(proxy, ban_duration=600)
                
                elif response.status_code == 429:
                    logger.warning(f"[Alibaba] 429 Too Many Requests - Pause...")
                    anti_detection.long_pause()
                    if proxy:
                        proxy_manager.report_failure(proxy, ban_duration=300)
                
            except Exception as e:
                logger.warning(f"[Alibaba] Erreur tentative {attempt + 1}: {e}")
                if proxy:
                    proxy_manager.report_failure(proxy)
        
        return None
    
    def get_category_urls(self) -> List[str]:
        """URLs de recherche pour chaque catégorie"""
        urls = []
        
        search_terms = [
            "smartphone", "mobile phone", "laptop computer", "tablet",
            "led tv", "television", "fan ventilator", "air conditioner",
            "refrigerator", "washing machine", "solar panel", "generator",
            "clothing", "shoes", "bags", "watches",
            "furniture", "home decor", "kitchen appliances",
            "car parts", "tires", "battery",
            "beauty products", "cosmetics", "perfume"
        ]
        
        for term in search_terms:
            url = f"{self.search_url}?SearchText={term.replace(' ', '+')}&country=CN"
            urls.append(url)
        
        return urls
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser les résultats de recherche Alibaba"""
        products = []
        
        # Sélecteurs Alibaba (peuvent changer)
        selectors = [
            '.organic-list-offer-outter',
            '.list-no-v2-outter',
            '[class*="offer-list"] > div',
            '.J-offer-wrapper',
        ]
        
        articles = []
        for sel in selectors:
            articles = soup.select(sel)
            if articles:
                break
        
        # Alternative: chercher par data attributes
        if not articles:
            articles = soup.find_all('div', {'data-offer-id': True})
        
        for article in articles:
            try:
                product = self._parse_alibaba_product(article)
                if product:
                    products.append(product)
            except Exception as e:
                logger.debug(f"Erreur parsing produit: {e}")
                continue
        
        return products
    
    def _parse_alibaba_product(self, article) -> Optional[Dict]:
        """Parser un produit Alibaba"""
        # Titre
        title_elem = article.select_one('.elements-title-normal, h2 a, [class*="title"] a')
        if not title_elem:
            return None
        
        name = clean_text(title_elem.get_text())
        if not name or len(name) < 5:
            return None
        
        # Prix
        price_elem = article.select_one('.elements-offer-price-normal, [class*="price"]')
        price_min = None
        price_max = None
        
        if price_elem:
            price_text = price_elem.get_text()
            # Format: "$1.50 - $3.00" ou "$2.50"
            prices = re.findall(r'\$?\s*([\d,.]+)', price_text)
            if prices:
                price_min = clean_price(prices[0])
                price_max = clean_price(prices[-1]) if len(prices) > 1 else price_min
        
        if not price_min:
            return None
        
        # MOQ (Minimum Order Quantity)
        moq = 1
        moq_elem = article.select_one('[class*="moq"], [class*="min-order"]')
        if moq_elem:
            moq_text = moq_elem.get_text()
            moq_match = re.search(r'(\d+)', moq_text)
            if moq_match:
                moq = int(moq_match.group(1))
        
        # Nom du fournisseur
        supplier_elem = article.select_one('.company-name a, [class*="supplier"] a, [class*="company"] a')
        supplier_name = clean_text(supplier_elem.get_text()) if supplier_elem else None
        
        # Années d'expérience
        years_elem = article.select_one('[class*="year"], [class*="experience"]')
        years = 0
        if years_elem:
            years_match = re.search(r'(\d+)\s*(?:yr|year|ans)', years_elem.get_text(), re.I)
            if years_match:
                years = int(years_match.group(1))
        
        # Fournisseur vérifié
        verified = bool(article.select_one('[class*="verified"], [class*="gold"], .verified-icon'))
        
        # Image
        img_elem = article.select_one('img')
        image_url = None
        if img_elem:
            image_url = img_elem.get('data-src') or img_elem.get('src')
        
        # Lien produit
        link_elem = article.select_one('a[href*="/product-detail/"]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('//'):
                product_url = 'https:' + href
            elif href.startswith('/'):
                product_url = self.base_url + href
            else:
                product_url = href
        
        # Lien fournisseur
        supplier_url = None
        if supplier_elem:
            supplier_href = supplier_elem.get('href', '')
            if supplier_href:
                if supplier_href.startswith('//'):
                    supplier_url = 'https:' + supplier_href
                elif supplier_href.startswith('/'):
                    supplier_url = self.base_url + supplier_href
        
        return {
            'type': 'fournisseur',
            'nom_produit': name,
            'prix_usine': price_min,
            'prix_min': price_min,
            'prix_max': price_max,
            'devise': 'USD',
            'moq': moq,
            'nom_fournisseur': supplier_name,
            'annees_experience': years,
            'verifie': verified,
            'image_url': image_url,
            'product_url': product_url,
            'supplier_url': supplier_url,
            'source': 'Alibaba',
            'score_fiabilite': 0.8 if verified else 0.5
        }
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Trouver la page suivante"""
        next_link = soup.select_one('a.next, [class*="pagination"] a[rel="next"]')
        if next_link:
            href = next_link.get('href', '')
            if href.startswith('//'):
                return 'https:' + href
            elif href.startswith('/'):
                return self.base_url + href
            elif href.startswith('http'):
                return href
        
        # Essayer d'incrémenter page=X
        if 'page=' in current_url:
            match = re.search(r'page=(\d+)', current_url)
            if match:
                current_page = int(match.group(1))
                return re.sub(r'page=\d+', f'page={current_page + 1}', current_url)
        else:
            return current_url + '&page=2'
        
        return None
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        """Parser les détails d'un produit (page individuelle)"""
        return None
