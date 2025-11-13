#!/usr/bin/env python3
import os,sys,argparse,subprocess
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
A=os.path.join(RISN_HOME,"agents")
p=argparse.ArgumentParser()
p.add_argument("--role")
args=p.parse_args()
role=args.role
if role=="design":
    subprocess.run([sys.executable, os.path.join(A,"agent_design.py"), "--product", "sim-product", "--variants","1"])
elif role=="product":
    subprocess.run([sys.executable, os.path.join(A,"agent_product.py"), "--from","sim-product.png","--meta",'{"title":"Sim"}'])
else:
    print("unknown role")
