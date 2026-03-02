# ============================================================
# GESTIONNAIRE DE PROXIES - Rotation intelligente
# ============================================================

import random
import requests
import time
import logging
from typing import List, Dict, Optional
from dataclasses import dataclass, field
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

@dataclass
class Proxy:
    """Représentation d'un proxy"""
    host: str
    port: int
    protocol: str = "http"
    username: Optional[str] = None
    password: Optional[str] = None
    country: str = "unknown"
    speed: float = 0.0  # Temps de réponse en secondes
    success_count: int = 0
    fail_count: int = 0
    last_used: Optional[datetime] = None
    banned_until: Optional[datetime] = None
    
    @property
    def url(self) -> str:
        """URL complète du proxy"""
        if self.username and self.password:
            return f"{self.protocol}://{self.username}:{self.password}@{self.host}:{self.port}"
        return f"{self.protocol}://{self.host}:{self.port}"
    
    @property
    def dict_format(self) -> Dict:
        """Format dictionnaire pour requests"""
        return {
            "http": self.url,
            "https": self.url
        }
    
    @property
    def success_rate(self) -> float:
        """Taux de succès"""
        total = self.success_count + self.fail_count
        return self.success_count / total if total > 0 else 0.5
    
    @property
    def is_banned(self) -> bool:
        """Vérifier si le proxy est temporairement banni"""
        if self.banned_until is None:
            return False
        return datetime.now() < self.banned_until


class ProxyManager:
    """Gestionnaire de rotation de proxies"""
    
    def __init__(self):
        self.proxies: List[Proxy] = []
        self.current_index = 0
        self.min_delay_between_uses = 5  # Secondes minimum entre utilisations
        
    def add_proxy(self, proxy: Proxy):
        """Ajouter un proxy"""
        self.proxies.append(proxy)
        logger.info(f"Proxy ajouté: {proxy.host}:{proxy.port}")
    
    def add_proxies_from_list(self, proxy_list: List[str]):
        """
        Ajouter des proxies depuis une liste de chaînes
        Format: host:port ou host:port:user:pass ou protocol://host:port
        """
        for proxy_str in proxy_list:
            try:
                proxy = self._parse_proxy_string(proxy_str)
                if proxy:
                    self.add_proxy(proxy)
            except Exception as e:
                logger.warning(f"Impossible de parser le proxy: {proxy_str} - {e}")
    
    def _parse_proxy_string(self, proxy_str: str) -> Optional[Proxy]:
        """Parser une chaîne de proxy"""
        # Format: protocol://user:pass@host:port
        if "://" in proxy_str:
            protocol = proxy_str.split("://")[0]
            rest = proxy_str.split("://")[1]
            
            if "@" in rest:
                auth, host_port = rest.rsplit("@", 1)
                username, password = auth.split(":", 1)
                host, port = host_port.split(":")
                return Proxy(host=host, port=int(port), protocol=protocol, 
                           username=username, password=password)
            else:
                host, port = rest.split(":")
                return Proxy(host=host, port=int(port), protocol=protocol)
        
        # Format: host:port:user:pass
        parts = proxy_str.split(":")
        if len(parts) == 2:
            return Proxy(host=parts[0], port=int(parts[1]))
        elif len(parts) == 4:
            return Proxy(host=parts[0], port=int(parts[1]), 
                        username=parts[2], password=parts[3])
        
        return None
    
    def load_free_proxies(self):
        """Charger des proxies gratuits depuis des APIs publiques"""
        free_proxy_apis = [
            "https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=10000&country=all",
            "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt",
            "https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt",
        ]
        
        for api_url in free_proxy_apis:
            try:
                response = requests.get(api_url, timeout=10)
                if response.status_code == 200:
                    lines = response.text.strip().split("\n")
                    for line in lines[:100]:  # Limiter à 100 proxies par source
                        line = line.strip()
                        if line and ":" in line:
                            parts = line.split(":")
                            if len(parts) >= 2:
                                try:
                                    proxy = Proxy(host=parts[0], port=int(parts[1]))
                                    self.proxies.append(proxy)
                                except:
                                    pass
                    logger.info(f"Chargé des proxies depuis {api_url}")
            except Exception as e:
                logger.warning(f"Erreur chargement proxies: {e}")
        
        logger.info(f"Total proxies chargés: {len(self.proxies)}")
    
    def get_proxy(self, prefer_fast: bool = True) -> Optional[Proxy]:
        """
        Obtenir le prochain proxy disponible
        
        Args:
            prefer_fast: Privilégier les proxies rapides avec bon taux de succès
        """
        if not self.proxies:
            return None
        
        # Filtrer les proxies non bannis
        available = [p for p in self.proxies if not p.is_banned]
        
        if not available:
            # Réinitialiser les bans si tous sont bannis
            for p in self.proxies:
                p.banned_until = None
            available = self.proxies
        
        if prefer_fast:
            # Trier par score (succès rate + vitesse)
            available.sort(key=lambda p: (p.success_rate, -p.speed), reverse=True)
        else:
            # Rotation simple
            random.shuffle(available)
        
        # Prendre le premier qui n'a pas été utilisé récemment
        for proxy in available:
            if proxy.last_used is None:
                proxy.last_used = datetime.now()
                return proxy
            
            time_since_use = (datetime.now() - proxy.last_used).total_seconds()
            if time_since_use >= self.min_delay_between_uses:
                proxy.last_used = datetime.now()
                return proxy
        
        # Si tous ont été utilisés récemment, prendre le premier
        proxy = available[0]
        proxy.last_used = datetime.now()
        return proxy
    
    def report_success(self, proxy: Proxy, response_time: float = 0):
        """Signaler un succès pour un proxy"""
        proxy.success_count += 1
        proxy.speed = response_time
        logger.debug(f"Proxy {proxy.host} - Succès (total: {proxy.success_count})")
    
    def report_failure(self, proxy: Proxy, ban_duration: int = 300):
        """
        Signaler un échec pour un proxy
        
        Args:
            ban_duration: Durée du ban temporaire en secondes
        """
        proxy.fail_count += 1
        
        # Bannir temporairement si trop d'échecs
        if proxy.fail_count >= 3 and proxy.success_rate < 0.3:
            proxy.banned_until = datetime.now() + timedelta(seconds=ban_duration)
            logger.warning(f"Proxy {proxy.host} banni pour {ban_duration}s")
        
        logger.debug(f"Proxy {proxy.host} - Échec (total: {proxy.fail_count})")
    
    def test_proxy(self, proxy: Proxy, test_url: str = "https://httpbin.org/ip") -> bool:
        """Tester si un proxy fonctionne"""
        try:
            start = time.time()
            response = requests.get(
                test_url,
                proxies=proxy.dict_format,
                timeout=10
            )
            elapsed = time.time() - start
            
            if response.status_code == 200:
                proxy.speed = elapsed
                return True
        except:
            pass
        return False
    
    def test_all_proxies(self, test_url: str = "https://httpbin.org/ip"):
        """Tester tous les proxies et supprimer les morts"""
        logger.info(f"Test de {len(self.proxies)} proxies...")
        
        working = []
        for proxy in self.proxies:
            if self.test_proxy(proxy, test_url):
                working.append(proxy)
                logger.info(f"✓ {proxy.host}:{proxy.port} - {proxy.speed:.2f}s")
            else:
                logger.info(f"✗ {proxy.host}:{proxy.port}")
        
        self.proxies = working
        logger.info(f"Proxies fonctionnels: {len(self.proxies)}")
    
    def get_stats(self) -> Dict:
        """Statistiques des proxies"""
        total = len(self.proxies)
        banned = sum(1 for p in self.proxies if p.is_banned)
        avg_success = sum(p.success_rate for p in self.proxies) / total if total > 0 else 0
        
        return {
            "total": total,
            "available": total - banned,
            "banned": banned,
            "avg_success_rate": round(avg_success * 100, 2)
        }


# Liste de proxies premium (à remplacer par vos propres proxies)
PREMIUM_PROXIES = [
    # Format: "host:port" ou "host:port:user:pass"
    # Ajoutez vos proxies ici
]

# Instance globale
proxy_manager = ProxyManager()
