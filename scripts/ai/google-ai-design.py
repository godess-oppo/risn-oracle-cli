#!/usr/bin/env python3
import os
import requests
import json
import sys

def generate_design_with_gemini(prompt, product_slug, variant_num):
    api_key = os.getenv('GOOGLE_AI_KEY')
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={api_key}"
    
    headers = {
        'Content-Type': 'application/json'
    }
    
    # Enhanced fashion design prompt
    enhanced_prompt = f"""
    Create a detailed fashion design description for: {prompt}
    Product: {product_slug}
    Variant: {variant_num}
    
    Provide a detailed description of:
    - Garment type and silhouette
    - Color palette and patterns
    - Materials and textures
    - Unique design elements
    - Target audience and occasion
    
    Return as JSON format.
    """
    
    data = {
        "contents": [{
            "parts": [{
                "text": enhanced_prompt
            }]
        }]
    }
    
    try:
        response = requests.post(url, headers=headers, json=data)
        if response.status_code == 200:
            result = response.json()
            design_description = result['candidates'][0]['content']['parts'][0]['text']
            return {
                "status": "success",
                "provider": "google_ai",
                "design_description": design_description,
                "product": product_slug,
                "variant": variant_num
            }
        else:
            return {
                "status": "error",
                "provider": "google_ai", 
                "error": f"API error: {response.status_code}",
                "response": response.text
            }
    except Exception as e:
        return {
            "status": "error",
            "provider": "google_ai",
            "error": str(e)
        }

if __name__ == "__main__":
    prompt = sys.argv[1] if len(sys.argv) > 1 else "fashion design"
    product = sys.argv[2] if len(sys.argv) > 2 else "test-product"
    variant = sys.argv[3] if len(sys.argv) > 3 else "0"
    
    result = generate_design_with_gemini(prompt, product, variant)
    print(json.dumps(result, indent=2))
