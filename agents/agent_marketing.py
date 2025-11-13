#!/usr/bin/env python3
"""
Agent: Marketing
- Generates marketing assets (copy + placeholder media).
- Queues marketing tasks (simulated).
"""
import os,sys,json,argparse,time,random
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
ACTIONS=f"{RISN_HOME}/actions"
DESIGNS=f"{RISN_HOME}/designs"
AUDIT=f"{RISN_HOME}/audit.log"

def audit(msg):
    print(f"[MARKETING] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"marketing","msg":msg})+"\n")

def write_plan(name, rollback):
    fname=os.path.join(ACTIONS,f"plan-{int(time.time())}-{name}.json")
    with open(fname,"w") as f:
        json.dump({"name":name,"rollback":rollback,"time":time.time()},f,indent=2)
    audit(f"wrote plan {fname}")

def generate_campaign(product, kind):
    # simple templates
    text_templates={
      "email": f"Launch: {product} is live — shop now!",
      "social": f"New drop: {product} — link in bio.",
      "shortvideo": f"Showcasing {product}: watch now!"
    }
    text=text_templates.get(kind,"Check out our new product!")
    filename=f"{RISN_HOME}/designs/asset-{product}-{int(time.time())}.txt"
    with open(filename,"w") as f:
        f.write(text)
    audit(f"generated marketing asset {filename}")
    write_plan("marketing.asset", f"rm -f {filename}")
    return filename

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--type", default="social")
    p.add_argument("--product", default="unknown")
    args=p.parse_args()
    audit(f"marketing agent started type={args.type} product={args.product}")
    asset=generate_campaign(args.product, args.type)
    print(json.dumps({"asset":asset}))
