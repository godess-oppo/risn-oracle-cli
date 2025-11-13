#!/usr/bin/env python3
import json
import sys
import os

def main():
    try:
        # Parse arguments
        design_files = sys.argv[1] if len(sys.argv) > 1 else ""
        meta_json = sys.argv[2] if len(sys.argv) > 2 else "{}"
        
        print(f"Creating product from designs: {design_files}")
        print(f"With metadata: {meta_json}")
        
        # Parse metadata
        try:
            meta = json.loads(meta_json)
        except json.JSONDecodeError:
            meta = {"category": "clothing", "error": "invalid_meta"}
        
        # Simulate product creation
        result = {
            "status": "success",
            "product_id": f"prod_{os.urandom(4).hex()}",
            "designs": design_files.split(",") if design_files else [],
            "metadata": meta,
            "created_at": "2024-01-01T00:00:00Z"
        }
        
        print(json.dumps(result, indent=2))
        
    except Exception as e:
        error_result = {
            "status": "error",
            "error": str(e),
            "message": "Product creation failed"
        }
        print(json.dumps(error_result, indent=2))
        sys.exit(1)

if __name__ == "__main__":
    main()
