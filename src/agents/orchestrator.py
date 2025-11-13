#!/usr/bin/env python3
"""
Orchestrator: coordinates design -> product -> marketing -> deploy -> analytics
- Runs continuously, supports canary deploys, health checks, rollbacks, drift detection.
- Writes explainable JSON logs and action plans to actions/.
"""
import os,sys,time,json,subprocess,traceback
from datetime import datetime
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
AGENTS=os.path.join(RISN_HOME,"agents")
ACTIONS=os.path.join(RISN_HOME,"actions")
AUDIT=os.path.join(RISN_HOME,"audit.log")
SLEEP_LOOP=int(os.environ.get("RISN_LOOP_SECONDS","30"))

def audit(msg,extra=None):
    l={"time":datetime.utcnow().isoformat()+"Z","msg":msg}
    if extra: l.update(extra)
    print("[ORCH]",msg)
    with open(AUDIT,"a") as f:
        f.write(json.dumps(l)+"\n")

def write_plan(name, rollback):
    fname=os.path.join(ACTIONS,f"plan-{int(time.time())}-{name}.json")
    with open(fname,"w") as f:
        json.dump({"name":name,"rollback":rollback,"time":time.time()},f,indent=2)
    audit(f"wrote plan {fname}")

def run_agent(agent, args=None, capture=True):
    cmd=[sys.executable, os.path.join(AGENTS,agent)]
    if args: cmd += args
    audit(f"running agent {agent} args={args}")
    try:
        r=subprocess.run(cmd, capture_output=capture, text=True, timeout=120)
        out=r.stdout.strip()
        audit(f"agent {agent} exit={r.returncode}")
        return r.returncode, out
    except Exception as e:
        audit(f"agent {agent} failed: {e}")
        return 99, str(e)

def pipeline_once():
    # DESIGN
    rc,out = run_agent("agent_design.py", ["--preset","auto","--product","autoprod","--variants","1","--audit","True"])
    if rc!=0:
        audit("design failed - abort pipeline",{"rc":rc})
        return False
    try:
        designs = json.loads(out).get("designs",[])
    except:
        designs=[]
    # PRODUCT
    if designs:
        rc,out = run_agent("agent_product.py", ["--from", designs[0], "--meta", '{"title":"Autoprod","price":1999}'])
        if rc!=0:
            audit("product creation failed - abort",{"rc":rc})
            return False
    # MARKETING
    rc,out = run_agent("agent_marketing.py", ["--type","social","--product","autoprod"])
    # DEPLOY (canary)
    rc,out = run_agent("agent_deploy.py", ["--target","docker","--stage","prod","--canary","true"])
    if rc==2:
        audit("canary failed - invoking ops heal and not promoting",{"rc":rc})
        run_agent("agent_ops.py", ["--auto","true"])
        return False
    elif rc!=0:
        audit("deploy failed - abort",{"rc":rc})
        run_agent("agent_ops.py", ["--auto","true"])
        return False
    # ANALYTICS
    rc,out = run_agent("agent_analytics.py", ["--forecast","14"])
    try:
        j=json.loads(out)
        if j.get("drift"):
            audit("drift detected by analytics - scheduling retrain and notifying",{"drift":j.get("delta")})
            write_plan("trigger.retrain", "manual: run retrain pipeline")
    except:
        pass
    audit("pipeline completed successfully")
    return True

def main():
    audit("orchestrator starting (loop seconds=%s)"%SLEEP_LOOP)
    while True:
        try:
            ok=pipeline_once()
            if not ok:
                audit("pipeline reported issues; sleeping before retry")
            time.sleep(SLEEP_LOOP)
        except KeyboardInterrupt:
            audit("orchestrator interrupted - exiting")
            break
        except Exception as e:
            audit("orchestrator exception: "+str(e))
            traceback.print_exc()
            time.sleep(10)

if __name__=="__main__":
    main()
