#!/usr/bin/env python3
"""
Agent: Design
- Generates designs (simulated) using SD-WebUI if available.
- Produces design files to designs/ and writes audit & plan file.
"""
import os,sys,json,argparse,time,random,subprocess
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
DESIGNS=f"{RISN_HOME}/designs"
ACTIONS=f"{RISN_HOME}/actions"
AUDIT=f"{RISN_HOME}/audit.log"

def audit(msg):
    print(f"[DESIGN] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"design","msg":msg})+"\n")

def write_plan(name, rollback_cmd):
    fname=os.path.join(ACTIONS,f"plan-{int(time.time())}-{name}.json")
    with open(fname,"w") as f:
        json.dump({"name":name,"rollback":rollback_cmd,"time":time.time()},f,indent=2)
    audit(f"wrote plan {fname}")

def call_sdwebui(prompt, outpath):
    # prefer local SD-WebUI API if defined
    url=os.environ.get("SD_WEBUI_URL","http://localhost:7860")
    try:
        # minimal attempt to call SD-WebUI txt2img API if available
        import requests
        payload={"prompt":prompt,"steps":20}
        r = requests.post(f"{url}/sdapi/v1/txt2img", json=payload, timeout=5)
        if r.ok:
            outfile=outpath
            with open(outfile,"wb") as f:
                f.write(r.content if isinstance(r.content,bytes) else r.text.encode())
            return outfile
    except Exception as e:
        audit(f"SD-WebUI unavailable or failed: {e}")
    # fallback: render placeholder image (binary) to simulate
    with open(outpath,"wb") as f:
        f.write(os.urandom(1024))
    return outpath

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--preset", default="default")
    p.add_argument("--product", default="untitled")
    p.add_argument("--variants", type=int, default=1)
    p.add_argument("--audit", default="False")
    args=p.parse_args()
    audit(f"design agent started preset={args.preset} product={args.product} variants={args.variants}")
    designs=[]
    for i in range(int(args.variants)):
        name=f"{args.product}-{args.preset}-{i}.png"
        out=os.path.join(DESIGNS,name)
        prompt=f"RISN design {args.product} preset {args.preset} variant {i}"
        written=call_sdwebui(prompt,out)
        audit(f"wrote design {written}")
        write_plan(f"design:{name}", f"rm -f {written}")
        designs.append(written)
        time.sleep(0.5+random.random()*0.5)
    print(json.dumps({"designs":designs}))
if __name__=="__main__":
    main()
