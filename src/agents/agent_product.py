#!/usr/bin/env python3
"""
Agent: Product
- Reads a design file placeholder and creates a product entry (simulated).
- Integrates with Medusa API if MEDUSA_BASE_URL & MEDUSA_API_KEY are set.
"""
import os,sys,json,argparse,time,random
import requests
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
ACTIONS=f"{RISN_HOME}/actions"
AUDIT=f"{RISN_HOME}/audit.log"
MEDUSA_BASE=os.environ.get("MEDUSA_BASE_URL","http://localhost:9000")
MEDUSA_KEY=os.environ.get("MEDUSA_API_KEY","")

def audit(msg):
    print(f"[PRODUCT] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"product","msg":msg})+"\n")

def write_plan(name, rollback):
    fname=os.path.join(ACTIONS,f"plan-{int(time.time())}-{name}.json")
    with open(fname,"w") as f:
        json.dump({"name":name,"rollback":rollback,"time":time.time()},f,indent=2)
    audit(f"wrote plan {fname}")

def push_to_medusa(payload):
    if not MEDUSA_KEY:
        audit("MEDUSA_API_KEY not set; simulating product push")
        return {"id":"sim-"+str(int(time.time()))}
    try:
        r=requests.post(f"{MEDUSA_BASE}/store/products", json=payload, timeout=5, headers={"Authorization":f"Bearer {MEDUSA_KEY}"})
        if r.ok:
            return r.json()
    except Exception as e:
        audit(f"Medusa push failed: {e}")
    return {"id":"sim-"+str(int(time.time()))}

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--from", dest="src", default="")
    p.add_argument("--meta", default="{}")
    args=p.parse_args()
    audit(f"product agent started from={args.src}")
    meta=json.loads(args.meta if args.meta else "{}")
    payload={"title": meta.get("title","RISN Product"), "thumbnail": args.src, "variants":[{"sku":"AUTO-"+str(int(time.time())),"price":meta.get("price",1999)}]}
    resp=push_to_medusa(payload)
    audit(f"product created: {resp}")
    write_plan("product.create", f"delete_product {resp.get('id')}")
    print(json.dumps(resp))
if __name__=="__main__":
    main()
