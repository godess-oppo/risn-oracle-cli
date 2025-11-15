import asyncio
from typing import Dict, List
from ..api.printify import PrintifyAPI
from ..api.printfull import PrintfulAPI
from ..api.spod import SPODAPI
from ..api.gelato import GelatoAPI

class MultiPlatformPublisher:
    def __init__(self):
        self.apis = {
            "printify": PrintifyAPI(),
            "printfull": PrintfulAPI(),
            "spod": SPODAPI(),
            "gelato": GelatoAPI(),
        }
    
    async def deploy(self, design_id: str, platforms: List[str], 
                     manual_price: str = None, auto_optimize: bool = False) -> Dict:
        results = {}
        
        tasks = []
        for platform in platforms:
            if platform in self.apis:
                task = asyncio.create_task(
                    self.apis[platform].publish_design(
                        design_id=design_id,
                        price=manual_price,
                        auto_optimize=auto_optimize
                    )
                )
                tasks.append((platform, task))
        
        for platform, task in tasks:
            try:
                result = await asyncio.wait_for(task, timeout=60.0)
                results[platform] = {"success": True, **result}
            except Exception as e:
                results[platform] = {"success": False, "error": str(e)}
        
        return results
