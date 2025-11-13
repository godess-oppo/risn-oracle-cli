#!/usr/bin/env python3
import os
import requests
import json
import sys

def generate_design_with_huggingface(prompt, product_slug, variant_num):
    api_token = os.getenv('HUGGINGFACE_TOKEN')
    
    # Try stable diffusion or other image models
    url = "https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5"
    headers = {"Authorization": f"Bearer {api_token}"}
    
    fashion_prompt = f"fashion design, {prompt}, professional clothing design, high quality, detailed"
    
    try:
        response = requests.post(url, headers=headers, json={"inputs": fashion_prompt})
        if response.status_code == 200:
            # Save the generated image
            image_path = f"designs/{product_slug}-{variant_num}-hf.png"
            with open(image_path, "wb") as f:
                f.write(response.content)
            
            return {
                "status": "success", 
                "provider": "huggingface",
                "image_path": image_path,
                "product": product_slug,
                "variant": variant_num
            }
        else:
            return {
                "status": "error",
                "provider": "huggingface",
                "error": f"API error: {response.status_code}",
                "response": response.text
            }
    except Exception as e:
        return {
            "status": "error",
            "provider": "huggingface", 
            "error": str(e)
        }

if __name__ == "__main__":
    prompt = sys.argv[1] if len(sys.argv) > 1 else "fashion design"
    product = sys.argv[2] if len(sys.argv) > 2 else "test-product"
    variant = sys.argv[3] if len(sys.argv) > 3 else "0"
    
    result = generate_design_with_huggingface(prompt, product, variant)
    print(json.dumps(result, indent=2))
