#!/usr/bin/env python3
import sys

def check_dependencies():
    missing = []
    
    try:
        import requests
        print("✅ requests module available")
    except ImportError:
        missing.append("requests")
        print("❌ requests module missing")
    
    try:
        import PIL
        print("✅ PIL/Pillow module available")
    except ImportError:
        missing.append("PIL/Pillow")
        print("❌ PIL/Pillow module missing")
    
    try:
        import json
        print("✅ json module available")
    except ImportError:
        missing.append("json")
        print("❌ json module missing")
    
    return missing

if __name__ == "__main__":
    missing = check_dependencies()
    if missing:
        print(f"\n🚨 Missing dependencies: {', '.join(missing)}")
        print("Run: pip install " + " ".join(missing))
        sys.exit(1)
    else:
        print("\n🎉 All dependencies are available!")
        sys.exit(0)
