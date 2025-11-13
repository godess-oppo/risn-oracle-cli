#!/usr/bin/env python3
"""
quantum_forge.py — Quantum-Forge minimal multimodal CLI
Dependencies: Pillow, numpy
Run: python3 quantum_forge.py --input products.csv --out out_zip
"""
from __future__ import annotations
import argparse, csv, json, os, sys, time, math, base64, struct, wave, random, shutil, subprocess
from pathlib import Path
from typing import List, Dict, Any
from datetime import datetime

# External (2): Pillow, numpy
try:
    from PIL import Image, ImageDraw, ImageFont
    import numpy as np
except Exception:
    print("Install dependencies: pip install Pillow numpy"); raise

# ---------------- Config ----------------
PLUGINS_SCHEMA = {
    "type": "object",
    "properties": {
        "image_backend": {"type": "string"},
        "audio_backend": {"type": "string"}
    }
}
STATE_FILE = Path.home() / ".quantum_forge_state.json"
BADGE_MILESTONE = 1000

# ---------- Helpers ----------
def load_products(path: str) -> List[Dict[str,str]]:
    out=[]
    with open(path, newline='', encoding='utf-8') as f:
        rdr=csv.DictReader(f)
        for r in rdr: out.append(r)
    return out

def deterministic_palette(seed: str, n=5):
    rnd = random.Random(hash(seed))
    return [tuple(int(rnd.random()*255) for _ in range(3)) for _ in range(n)]

def gen_image_placeholder(prompt: str, outpath:Path, glitch:bool=False) -> None:
    """Procedural photoreal placeholder (can be replaced by plugin)"""
    w,h = 1024,1024
    arr = np.zeros((h,w,3), dtype=np.uint8)
    pal = deterministic_palette(prompt,5)
    for i,col in enumerate(pal):
        y0 = int((i/len(pal))*h)
        y1 = int(((i+1)/len(pal))*h)
        arr[y0:y1,:,:] = col
    # add simple noise & circular vignette
    noise = (np.random.RandomState(abs(hash(prompt))%2**32).randint(0,50,(h,w,1))).astype(np.uint8)
    arr = np.clip(arr + noise, 0,255)
    img = Image.fromarray(arr, 'RGB').resize((1024,1024))
    draw = ImageDraw.Draw(img)
    draw.text((20,20), prompt[:120], fill=(255,255,255))
    if glitch:
        # pixel-glitch overlay: shift rows
        px = img.load()
        for row in range(100,200):
            img.paste(img.crop((0,row,1024,row+1)).transpose(Image.FLIP_LEFT_RIGHT), (math.floor((row*3)%30),row))
    img.save(outpath, "PNG", optimize=True)

def gen_gltf_simple(prompt: str, outpath:Path) -> None:
    """Emit a tiny embedded-gltf (single colored low-poly quad)"""
    # simple square made of two triangles
    positions = [ -0.5,-0.5,0.0, 0.5,-0.5,0.0, 0.5,0.5,0.0, -0.5,0.5,0.0 ]
    indices = [0,1,2, 0,2,3]
    # pack floats and uint16 indices into binary buffer
    buf_positions = struct.pack('<'+'f'*len(positions), *positions)
    buf_indices = struct.pack('<'+'H'*len(indices), *indices)
    buffer_bytes = buf_positions + buf_indices
    b64 = base64.b64encode(buffer_bytes).decode('ascii')
    gltf = {
        "asset":{"version":"2.0"},
        "buffers":[{"uri":"data:application/octet-stream;base64,"+b64,"byteLength":len(buffer_bytes)}],
        "bufferViews":[
            {"buffer":0,"byteOffset":0,"byteLength":len(buf_positions),"target":34962},
            {"buffer":0,"byteOffset":len(buf_positions),"byteLength":len(buf_indices),"target":34963}
        ],
        "accessors":[
            {"bufferView":0,"componentType":5126,"count":4,"type":"VEC3","max":[0.5,0.5,0],"min":[-0.5,-0.5,0]},
            {"bufferView":1,"componentType":5123,"count":6,"type":"SCALAR"}
        ],
        "meshes":[{"primitives":[{"attributes":{"POSITION":0},"indices":1}]}],
        "nodes":[{"mesh":0}],
        "scenes":[{"nodes":[0]}],
        "scene":0
    }
    outpath.write_text(json.dumps(gltf))

def gen_audio_prompt(prompt: str, outpath:Path) -> str:
    """Generate a short WAV mood-track (sine mash). Returns filename (mp3 if converted)"""
    sr=22050; duration=2.0
    t = np.linspace(0,duration,int(sr*duration),False)
    # base freq from hash
    f = 220 + (abs(hash(prompt))%400)
    audio = (0.5*np.sin(2*np.pi*f*t) + 0.25*np.sin(2*np.pi*(f*1.5)*t)).astype(np.float32)
    # ADSR fade
    fade = np.linspace(0,1,int(sr*0.05))
    audio[:len(fade)] *= fade
    audio[-len(fade):] *= fade[::-1]
    # write WAV
    wavpath = outpath.with_suffix('.wav')
    with wave.open(str(wavpath),'wb') as wf:
        wf.setnchannels(1); wf.setsampwidth(2); wf.setframerate(sr)
        ints = (audio * 32767).astype('<h')
        wf.writeframes(ints.tobytes())
    # try ffmpeg -> mp3
    mp3path = outpath.with_suffix('.mp3')
    if shutil.which("ffmpeg"):
        subprocess.run(["ffmpeg","-y","-i",str(wavpath), str(mp3path)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        wavpath.unlink(missing_ok=True)
        return str(mp3path.name)
    return str(wavpath.name)

def gen_svg_board(prompt: str, outpath:Path) -> None:
    colors = deterministic_palette(prompt,4)
    svg = ["<svg xmlns='http://www.w3.org/2000/svg' width='1200' height='600'>"]
    x=20
    for i,c in enumerate(colors):
        svg.append(f"<rect x='{x}' y='20' width='280' height='200' fill='rgb{c}' rx='20' />")
        x+=300
    svg.append(f"<text x='20' y='560' font-size='28' fill='#222'>{prompt[:80]}</text></svg>")
    outpath.write_text("\n".join(svg))

def make_catalog(items:List[Dict[str,Any]], outdir:Path) -> None:
    parts=[]
    for it in items:
        parts.append(f"""
<article class='card'>
  <img src='{it['image']}' alt='{it['title']}' loading='lazy'/>
  <h3>{it['title']}</h3>
  <p>{it['prompt']}</p>
</article>""")
    html=f"""<!doctype html>
<html><head><meta charset='utf-8'><meta name='description' content='Quantum-Forge catalog'>
<meta name='viewport' content='width=device-width,initial-scale=1'/>
<title>Quantum-Forge Catalog</title>
<style>body{{font-family:system-ui}} .card{{display:inline-block;width:240px;margin:8px}}</style></head>
<body><h1>Mini Store</h1><main>{''.join(parts)}</main></body></html>"""
    (outdir/"catalog.html").write_text(html)

def write_manifest(items:List[Dict[str,Any]], outdir:Path) -> None:
    (outdir/"manifest.json").write_text(json.dumps({"generated":items,"generated_at":datetime.utcnow().isoformat()+"Z"}, indent=2))

def write_design_log(meta:Dict[str,Any], outdir:Path) -> None:
    md = ["# design-log","",f"generated_at: {meta.get('generated_at')}","model_backend: {meta.get('model_backend')}","compute_note: {meta.get('compute_note')}","future_trend_insight: "+meta.get('insight'),""]
    (outdir/"design-log.md").write_text("\n".join(md))

def load_state()->Dict[str,int]:
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    return {"total_generated":0}
def save_state(s:Dict[str,int])->None:
    STATE_FILE.write_text(json.dumps(s))

def badge_check_and_print(total:int, badge:str=""):
    if total>0 and total % BADGE_MILESTONE==0:
        art = r"""
  ____  _     _     _     __ _  __
 |  _ \| |__ (_)___| |__ / _(_)/ _|
 | |_) | '_ \| / __| '_ \ |_| | |_ 
 |  __/| | | | \__ \ | | |  _| |  _|
 |_|   |_| |_|_|___/_| |_|_| |_|_|  
"""
        print(f"\n🎉 Milestone reached: {total} assets generated 🎉\n{art}")

# ---------------- Main CLI ----------------
def main():
    parser=argparse.ArgumentParser(description="Quantum-Forge CLI — multimodal fashion asset generator")
    parser.add_argument("--input", required=True, help="CSV with sku,title,prompt")
    parser.add_argument("--out", default="qf_out", help="output directory (zipped)")
    parser.add_argument("--workers", type=int, default=1, help="parallelism (placeholder)")
    parser.add_argument("--badge", default="", help="badge commands: generate-1000-looks")
    parser.add_argument("--glitch-mode", action='store_true', help="apply pixel glitch overlay")
    args=parser.parse_args()

    outdir=Path(args.out); outdir.mkdir(parents=True, exist_ok=True)
    products=load_products(args.input)
    items=[]
    start=time.time()
    state=load_state()
    count=0

    for p in products:
        sku=p.get("sku") or f"item{count}"
        prompt = p.get("prompt") or p.get("title") or p.get("description","")
        # generate modalities
        imgname=f"{sku}.png"; gltf=f"{sku}.gltf"; audio=f"{sku}.wav"; svg=f"{sku}.svg"
        gen_image_placeholder(prompt, outdir/imgname, glitch=args.glitch_mode)
        gen_gltf_simple(prompt, outdir/gltf)
        audio_name = gen_audio_prompt(prompt, outdir/Path(sku))
        gen_svg_board(prompt, outdir/svg)
        items.append({"sku":sku,"title":p.get("title",""),"prompt":prompt,"image":imgname,"gltf":gltf,"audio":audio_name,"svg":svg})
        count+=1
        state["total_generated"] += 1
        badge_check_and_print(state["total_generated"], args.badge)

    make_catalog(items, outdir)
    write_manifest(items, outdir)
    insight = "Predicted palette: "+ ", ".join(str(c) for c in deterministic_palette(''.join([it['prompt'] for it in items]) ) )
    meta={"generated_at":datetime.utcnow().isoformat()+"Z","model_backend":"placeholder","compute_note":"local placeholder generators, plug in real backends","insight":insight}
    write_design_log(meta, outdir)
    save_state(state)

    # zip output
    zipname = Path(args.out).with_suffix(".zip")
    shutil.make_archive(str(Path(args.out)), 'zip', root_dir=str(outdir))
    print(f"Packaged → {zipname.name} ({len(items)} items)")

    # badge CLI unlock
    if args.badge.startswith("generate-"):
        n=int(args.badge.split("-")[-1])
        if state["total_generated"]>=n:
            print("\n🔓 Badge unlocked: Neural-Style-Fusion available (placeholder).\n")
    # short progress bar
    print("|" + "█"*20 + "|" + f" {int((time.time()-start)//1)}s runtime")
    return 0

if __name__=="__main__":
    sys.exit(main())
