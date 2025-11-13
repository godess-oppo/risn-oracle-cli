#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

# --------------------------------------------------------------
# Helper functions – each calls a local, open‑source model.
# --------------------------------------------------------------

def run_stable_diffusion(prompt: str, out_path: Path) -> None:
    """Call a local Stable Diffusion CLI (e.g. stable-diffusion-webui)"""
    command = [
        "python3",
        "scripts/txt2img.py",
        "--prompt", prompt,
        "--outdir", str(out_path.parent),
        "--steps", "30",
        "--cfg_scale", "7",
        "--width", "512",
        "--height", "512",
    ]
    subprocess.run(command, check=True)

def run_coqui_tts(prompt: str, out_path: Path) -> None:
    """Run Coqui TTS local inference."""
    command = [
        "tts",
        "--text", prompt,
        "--out_path", str(out_path),
        "--model_name", "tts_models/en/ljspeech/tacotron2-DDC",
        "--vocoder_name", "vocoder_models/en/ljspeech/glow-tts",
    ]
    subprocess.run(command, check=True)

def run_blender_pose(prompt: str, out_path: Path) -> None:
    """Generate a simple 3D pose using Blender's Python API."""
    # A minimal Blender script that creates a UV sphere and exports it.
    blender_script = f"""
import bpy
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

bpy.ops.mesh.primitive_uv_sphere_add(radius=1, location=(0,0,0))
obj = bpy.context.active_object
obj.name = "Pose"

# Export as glTF (holographic format)
bpy.ops.export_scene.gltf(filepath="{out_path}", export_format='GLTF_SEPARATE')
"""
    with open("tmp_blender.py", "w") as f:
        f.write(blender_script)

    command = ["blender", "--background", "--python", "tmp_blender.py"]
    subprocess.run(command, check=True)
    os.remove("tmp_blender.py")

# --------------------------------------------------------------
# Main CLI logic
# --------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="aurawear helper")
    parser.add_argument("prompt", help="Text prompt for all generators")
    args = parser.parse_args()

    base = Path.cwd()
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    out_dir = base / "outputs" / timestamp
    out_dir.mkdir(parents=True, exist_ok=True)

    # 1️⃣ Image
    img_path = out_dir / f"{timestamp}_outfit.png"
    run_stable_diffusion(args.prompt, img_path)

    # 2️⃣ Audio
    aud_path = out_dir / f"{timestamp}_ambient.wav"
    run_coqui_tts(args.prompt, aud_path)

    # 3️⃣ 3D Model
    mdl_path = out_dir / f"{timestamp}_pose.glb"
    run_blender_pose(args.prompt, mdl_path)

    # Assemble the JSON result
    result = {
        "prompt": args.prompt,
        "timestamp": timestamp,
        "image_path": str(img_path.relative_to(base)),
        "audio_path": str(aud_path.relative_to(base)),
        "model_path": str(mdl_path.relative_to(base)),
    }
    print(json.dumps(result))

if __name__ == "__main__":
    main()
