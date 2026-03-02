# ============================================================
# SCRAPER 1688.com - Prix usine chinois
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

# Taux de change Yuan vers USD
CNY_TO_USD = 0.14

class China1688Scraper(BaseScraper):
    """
    Scraper pour 1688.com (Marché B2B chinois local - prix usine)
    NOTE: Site entièrement en chinois, prix en Yuan (CNY)
    """
    
    def __init__(self, site_config: Dict = None):
        default_config = {
            "name": "1688",
            "base_url": "https://www.1688.com",
            "country": "Chine",
            "country_code": "CHN",
            "currency": "CNY",
        }
        super().__init__(site_config or default_config)
        self.search_url = "https://s.1688.com/selloffer/offer_search.htm"
        self.request_count = 0
    
    def get_headers(self) -> Dict:
        """Headers 1688"""
        return anti_detection.get_1688_headers()
    
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
                    timeout=self.timeout,
                    cookies=anti_detection.get_cookies_template("1688")
                )
                
                if response.status_code == 200:
                    if proxy:
                        proxy_manager.report_success(proxy)
                    return BeautifulSoup(response.content, 'lxml')
                
                if proxy:
                    proxy_manager.report_failure(proxy)
                    
            except Exception as e:
                logger.warning(f"[1688] Erreur: {e}")
                if proxy:
                    proxy_manager.report_failure(proxy)
        
        return None
    
    def get_category_urls(self) -> List[str]:
        """URLs de recherche en chinois"""
        # Termes en chinois et anglais
        terms = [
            "手机", "smartphone",  # Téléphone
            "电脑", "laptop",      # Ordinateur
            "电视", "led tv",      # TV
            "风扇", "fan",         # Ventilateur
            "空调", "air conditioner",  # Climatiseur
            "太阳能板", "solar panel",  # Panneau solaire
            "服装", "clothing",    # Vêtements
            "鞋子", "shoes",       # Chaussures
            "家具", "furniture",   # Meubles
        ]
        
        urls = []
        for term in terms:
            url = f"{self.search_url}?keywords={term}"
            urls.append(url)
        return urls
    
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser les produits 1688"""
        products = []
        
        # Sélecteurs 1688
        articles = soup.select('.sm-offer-item, .offer-list-row, [class*="offer-item"]')
        
        if not articles:
            articles = soup.select('[data-offer-id], .card-container')
        
        for article in articles:
            try:
                product = self._parse_product(article)
                if product:
                    products.append(product)
            except:
                continue
        
        return products
    
    def _parse_product(self, article) -> Optional[Dict]:
        """Parser un produit 1688"""
        # Titre
        title_elem = article.select_one('.offer-title, h2, h3, [class*="title"]')
        if not title_elem:
            return None
        
        name = clean_text(title_elem.get_text())
        if not name:
            return None
        
        # Prix (en Yuan)
        price_elem = article.select_one('.price, [class*="price"]')
        price_cny = None
        
        if price_elem:
            price_text = price_elem.get_text()
            # Format: "¥12.50" ou "12.50-25.00"
            prices = re.findall(r'[\d.]+', price_text)
            if prices:
                price_cny = float(prices[0])
        
        if not price_cny:
            return None
        
        # Convertir en USD
        price_usd = round(price_cny * CNY_TO_USD, 2)
        
        # MOQ
        moq = 1
        moq_elem = article.select_one('[class*="moq"], [class*="min"]')
        if moq_elem:
            moq_match = re.search(r'(\d+)', moq_elem.get_text())
            if moq_match:
                moq = int(moq_match.group(1))
        
        # Nom fournisseur
        company_elem = article.select_one('.company-name, [class*="company"], [class*="supplier"]')
        company_name = clean_text(company_elem.get_text()) if company_elem else None
        
        # Années
        years = 0
        years_elem = article.select_one('[class*="year"]')
        if years_elem:
            years_match = re.search(r'(\d+)', years_elem.get_text())
            if years_match:
                years = int(years_match.group(1))
        
        # Image
        img_elem = article.select_one('img')
        image_url = img_elem.get('data-src') or img_elem.get('src') if img_elem else None
        
        # Lien
        link_elem = article.select_one('a[href*="offer"]')
        product_url = None
        if link_elem:
            href = link_elem.get('href', '')
            if href.startswith('//'):
                product_url = 'https:' + href
            else:
                product_url = href
        
        return {
            'type': 'fournisseur',
            'nom_produit': name,
            'prix_usine': price_usd,
            'prix_origine_cny': price_cny,
            'prix_min': price_usd,
            'prix_max': price_usd,
            'devise': 'USD',
            'moq': moq,
            'nom_fournisseur': company_name,
            'annees_experience': years,
            'image_url': image_url,
            'product_url': product_url,
            'source': '1688',
            'score_fiabilite': 0.6  # Prix usine mais moins vérifié
        }
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Page suivante"""
        next_link = soup.select_one('a.fui-next, [class*="next"] a')
        if next_link:
            href = next_link.get('href', '')
            if href.startswith('//'):
                return 'https:' + href
            return href
        return None
    
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        return None
