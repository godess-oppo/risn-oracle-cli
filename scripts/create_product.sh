#!/bin/bash
set -e

DESIGN_FILES="$1"
META_JSON="$2"

echo "Creating product from: $DESIGN_FILES"
echo "Metadata: $META_JSON"

# Generate product ID
PRODUCT_ID="prod_$(date +%s)"

# Create product JSON
PRODUCT_JSON=$(jq -n \
  --arg id "$PRODUCT_ID" \
  --arg designs "$DESIGN_FILES" \
  --argjson meta "$META_JSON" \
  '{
    product_id: $id,
    designs: ($designs | split(",")),
    metadata: $meta,
    status: "created",
    timestamp: "'$(date -Iseconds)'"
  }')

echo "$PRODUCT_JSON"

# Save to products directory
mkdir -p data/products
echo "$PRODUCT_JSON" > "data/products/${PRODUCT_ID}.json"

echo "Product created: $PRODUCT_ID"
