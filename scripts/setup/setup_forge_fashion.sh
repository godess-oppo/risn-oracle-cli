#!/bin/bash

# Set working directory to current location
WORKDIR=$(pwd)

# Create required directories with error handling
mkdir -p "$WORKDIR/looks" || echo "Error: Could not create looks directory"
mkdir -p "$WORKDIR/logs" || echo "Error: Could not create logs directory"
mkdir -p "$WORKDIR/previews" || echo "Error: Could not create previews directory"

# Create main executable file with proper permissions
cat > "$WORKDIR/forge-fashion.py" << 'EOF'
#!/usr/bin/env python3
import click
import diffusers
from pathlib import Path
from datetime import datetime

class ForgeFashion:
    def __init__(self):
        """Initialize ForgeOS Fashion CLI"""
        
        self.workdir = Path.cwd()
        self.log_path = self.workdir / "creation_log.md"
        self.setup_directories()

    def setup_directories(self):
        """Initialize project structure"""
        
        dirs = ["looks", "logs", "previews"]
        for d in dirs:
            (self.workdir / d).mkdir(exist_ok=True)

    def generate_lookbook(self, prompt: str):
        """Generate fashion lookbook images"""
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        image_path = self.workdir / "looks" / f"fashion_look_{timestamp}.png"

        pipe = diffusers.StableDiffusionPipeline.from_pretrained(
            "CompVis/stable-diffusion-v1-4",
            torch_dtype="float16"
        )
        pipe.to("cuda" if torch.cuda.is_available() else "cpu")

        image = pipe(prompt).images[0]
        image.save(image_path)

        self.log_generation(timestamp, prompt, image_path)
        return image_path

    def log_generation(self, timestamp: str, prompt: str, image_path: Path):
        """Document generation process in markdown"""
        
        with open(self.log_path, "a") as f:
            f.write(f"\n### Generation Log - {timestamp}\n\n")
            f.write(f"* Prompt: {prompt}\n")
            f.write(f"* Output: {image_path.relative_to(self.workdir)}\n\n")
            f.write("```markdown\n// ForgeOS Design Notes:\n// Generated using stable diffusion pipeline\n// Image saved in modular directory structure\n```")

@click.group()
def cli():
    """ForgeOS Fashion CLI - Self-aware fashion design automation"""
    pass

@cli.command()
@click.option('--prompt', '-p', required=True, help='Fashion design prompt')
def generate(prompt):
    """Generate fashion lookbook images"""
    
    forge = ForgeFashion()
    forge.generate_lookbook(prompt)
    click.echo(f"Generated fashion look saved in {forge.workdir}/looks")

@cli.command()
def preview():
    """Start local preview server"""
    
    import http.server
    import socketserver
    
    PORT = 8000
    handler = http.server.SimpleHTTPRequestHandler
    
    with socketserver.TCPServer(("", PORT), handler) as httpd:
        click.echo(f"Serving at port {PORT}")
        httpd.serve_forever()

if __name__ == '__main__':
    cli()
