import torch
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler
from pathlib import Path
from typing import List, Dict
import openai

class DesignGenerator:
    def __init__(self):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model_id = "stabilityai/stable-diffusion-3-medium"
        self.pipeline = None
        self.output_dir = Path.home() / "fashionforge" / "designs"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
    def load_model(self):
        if self.pipeline is None:
            self.pipeline = StableDiffusionPipeline.from_pretrained(
                self.model_id, torch_dtype=torch.float16 if self.device == "cuda" else torch.float32
            )
            self.pipeline.scheduler = DPMSolverMultistepScheduler.from_config(
                self.pipeline.scheduler.config
            )
            self.pipeline = self.pipeline.to(self.device)
    
    def create(self, prompt: str, style: str, garment: str, 
               colors: List[str], model: str, variations: int) -> List[Dict]:
        self.load_model()
        
        full_prompt = f"Fashion design, {style}, {garment}, {prompt}"
        if colors:
            full_prompt += f", colors: {', '.join(colors)}"
        full_prompt += ", textile pattern, print-ready vector, high detail"
        
        designs = []
        for i in range(variations):
            image = self.pipeline(
                full_prompt,
                negative_prompt="low quality, blurry, bad anatomy, watermark",
                num_inference_steps=30,
                guidance_scale=7.5,
                width=1024,
                height=1024
            ).images[0]
            
            design_id = f"ff-{int(time.time())}-{i:02d}"
            path = self.output_dir / f"{design_id}.png"
            image.save(path)
            
            designs.append({
                "id": design_id,
                "path": str(path),
                "prompt": full_prompt,
                "model": model
            })
        
        return designs
