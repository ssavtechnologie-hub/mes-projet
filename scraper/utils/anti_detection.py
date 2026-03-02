# ============================================================
# ANTI-DÉTECTION - Techniques d'évasion pour le scraping
# ============================================================

import random
import time
import hashlib
from typing import Dict, List, Optional
from fake_useragent import UserAgent

class AntiDetection:
    """Techniques anti-détection pour éviter les blocages"""
    
    def __init__(self):
        self.ua = UserAgent()
        
        # Liste de User-Agents pour les navigateurs chinois
        self.chinese_user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
            "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 QIHU 360SE",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 2345Explorer",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 SogouExplorer",
            "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
        ]
        
        # Langues pour simuler différentes régions
        self.languages = [
            "zh-CN,zh;q=0.9,en;q=0.8",
            "en-US,en;q=0.9,zh-CN;q=0.8",
            "fr-FR,fr;q=0.9,en;q=0.8",
            "en-GB,en;q=0.9",
        ]
        
        # Résolutions d'écran courantes
        self.screen_resolutions = [
            (1920, 1080), (1366, 768), (1536, 864), (1440, 900),
            (1280, 720), (2560, 1440), (3840, 2160)
        ]
    
    def get_random_headers(self, for_china: bool = False) -> Dict[str, str]:
        """
        Générer des headers aléatoires réalistes
        
        Args:
            for_china: Utiliser des headers optimisés pour sites chinois
        """
        if for_china:
            user_agent = random.choice(self.chinese_user_agents)
            accept_language = random.choice(["zh-CN,zh;q=0.9,en;q=0.8", "zh-CN,zh;q=0.9"])
        else:
            user_agent = self.ua.random
            accept_language = random.choice(self.languages)
        
        resolution = random.choice(self.screen_resolutions)
        
        headers = {
            "User-Agent": user_agent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
            "Accept-Language": accept_language,
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none",
            "Sec-Fetch-User": "?1",
            "Cache-Control": "max-age=0",
            "Sec-Ch-Ua": '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            "Sec-Ch-Ua-Mobile": "?0",
            "Sec-Ch-Ua-Platform": '"Windows"',
        }
        
        # Ajouter des headers aléatoires supplémentaires
        if random.random() > 0.5:
            headers["DNT"] = "1"
        
        if random.random() > 0.7:
            headers["Viewport-Width"] = str(resolution[0])
        
        return headers
    
    def get_alibaba_headers(self, referer: Optional[str] = None) -> Dict[str, str]:
        """Headers spécifiques pour Alibaba"""
        headers = self.get_random_headers(for_china=True)
        
        headers.update({
            "Referer": referer or "https://www.alibaba.com/",
            "Origin": "https://www.alibaba.com",
            "Host": "www.alibaba.com",
        })
        
        return headers
    
    def get_1688_headers(self, referer: Optional[str] = None) -> Dict[str, str]:
        """Headers spécifiques pour 1688.com"""
        headers = self.get_random_headers(for_china=True)
        
        headers.update({
            "Referer": referer or "https://www.1688.com/",
            "Origin": "https://www.1688.com",
            "Host": "www.1688.com",
            "Accept-Language": "zh-CN,zh;q=0.9",
        })
        
        return headers
    
    def random_delay(self, min_seconds: float = 1, max_seconds: float = 5):
        """Délai aléatoire entre les requêtes"""
        delay = random.uniform(min_seconds, max_seconds)
        # Ajouter parfois un délai plus long (simulation humaine)
        if random.random() > 0.9:
            delay += random.uniform(5, 15)
        time.sleep(delay)
    
    def human_like_delay(self):
        """Délai simulant un comportement humain"""
        # Distribution normale centrée sur 3 secondes
        delay = max(0.5, random.gauss(3, 1.5))
        time.sleep(delay)
    
    def generate_device_id(self) -> str:
        """Générer un ID de device unique mais cohérent"""
        # Basé sur un hash pour être reproductible par session
        seed = str(random.randint(100000, 999999))
        return hashlib.md5(seed.encode()).hexdigest()[:16]
    
    def get_cookies_template(self, site: str = "alibaba") -> Dict[str, str]:
        """Obtenir un template de cookies pour un site"""
        device_id = self.generate_device_id()
        timestamp = str(int(time.time() * 1000))
        
        if site == "alibaba":
            return {
                "ali_apache_id": f"{device_id}.{timestamp}",
                "cna": f"{device_id}",
                "taklid": f"{device_id}",
                "_m_h5_tk": f"{device_id}_{timestamp}",
            }
        elif site == "1688":
            return {
                "cna": f"{device_id}",
                "lid": f"guest{device_id[:8]}",
                "_m_h5_tk": f"{device_id}_{timestamp}",
            }
        elif site == "aliexpress":
            return {
                "aep_usuc_f": f"site=fra&c_tp=USD&region=FR&b_locale=fr_FR",
                "xman_us_f": f"x_lid={device_id}",
            }
        
        return {}
    
    def should_pause(self, request_count: int) -> bool:
        """Déterminer si on doit faire une pause longue"""
        # Pause toutes les 50-100 requêtes
        if request_count > 0 and request_count % random.randint(50, 100) == 0:
            return True
        return False
    
    def long_pause(self):
        """Pause longue pour simuler une session naturelle"""
        pause_time = random.uniform(30, 120)  # 30s à 2min
        print(f"⏸️  Pause de {pause_time:.0f} secondes...")
        time.sleep(pause_time)


# Instance globale
anti_detection = AntiDetection()
