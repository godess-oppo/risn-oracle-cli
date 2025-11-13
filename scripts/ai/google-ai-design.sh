#!/bin/bash
set -e

PROMPT="$1"
PRODUCT="$2"
VARIANT="$3"
API_KEY="$GOOGLE_AI_KEY"

ENHANCED_PROMPT="Create a detailed fashion design description for: $PROMPT. Product: $PRODUCT. Variant: $VARIANT. Provide detailed description of garment type, colors, materials, and design elements."

JSON_DATA=$(jq -n \
  --arg prompt "$ENHANCED_PROMPT" \
  '{
    "contents": [{
      "parts": [{
        "text": $prompt
      }]
    }]
  }')

RESPONSE=$(curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA")

if echo "$RESPONSE" | jq -e '.candidates[0].content' > /dev/null; then
    DESIGN_DESC=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')
    jq -n \
      --arg status "success" \
      --arg provider "google_ai" \
      --arg desc "$DESIGN_DESC" \
      --arg product "$PRODUCT" \
      --arg variant "$VARIANT" \
      '{
        status: $status,
        provider: $provider,
        design_description: $desc,
        product: $product,
        variant: $variant
      }'
else
    jq -n \
      --arg status "error" \
      --arg provider "google_ai" \
      --arg error "$RESPONSE" \
      '{
        status: $status,
        provider: $provider,
        error: $error
      }'
fi
