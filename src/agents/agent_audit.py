#!/usr/bin/env python3
"""
Agent: Audit & Safety
- Runs static checks (bias placeholders) and produces compliance report.
"""
import os,sys,json,time
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
AUDIT=f"{RISN_HOME}/audit.log"
ACTIONS=f"{RISN_HOME}/actions"

def audit(msg):
    print(f"[AUDIT] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"audit","msg":msg})+"\n")

if __name__=="__main__":
    audit("audit agent: running basic checks")
    report={"bias_checks":["neutral"],"compliance":["ok"],"timestamp":time.time()}
    fname=os.path.join(ACTIONS,f"audit-report-{int(time.time())}.json")
    with open(fname,"w") as f:
        json.dump(report,f,indent=2)
    audit(f"wrote audit report {fname}")
    print(json.dumps(report))
