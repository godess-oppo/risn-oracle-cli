#!/usr/bin/env python3
"""
Agent: Deploy
- Performs canary/staged deploys using local filesystem (simulated).
- Uses deployments/current -> symlink to latest. Supports rollback.
"""
import os,sys,json,argparse,time,shutil,subprocess
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
DEPLOY=f"{RISN_HOME}/deployments"
AUDIT=f"{RISN_HOME}/audit.log"
ACTIONS=f"{RISN_HOME}/actions"

def audit(msg):
    print(f"[DEPLOY] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"deploy","msg":msg})+"\n")

def write_plan(name, rollback):
    fname=os.path.join(ACTIONS,f"plan-{int(time.time())}-{name}.json")
    with open(fname,"w") as f:
        json.dump({"name":name,"rollback":rollback,"time":time.time()},f,indent=2)
    audit(f"wrote plan {fname}")

def health_check(target_dir):
    # simulated health check: succeed if marker file exists or random pass
    ok_file=os.path.join(target_dir,".healthy")
    if os.path.exists(ok_file):
        return True
    return (time.time() % 1) > 0.2  # 80% pass

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--target", default="docker")
    p.add_argument("--stage", default="prod")
    p.add_argument("--canary", default="false")
    args=p.parse_args()
    audit(f"deploy agent started target={args.target} stage={args.stage} canary={args.canary}")
    ts=int(time.time())
    new_release=os.path.join(DEPLOY,f"release-{ts}")
    os.makedirs(new_release, exist_ok=True)
    # simulate deploy artifacts
    with open(os.path.join(new_release,"index.txt"),"w") as f:
        f.write(f"release {ts}")
    # write healthy marker 90% of the time
    if (ts % 10) != 0:
        open(os.path.join(new_release,".healthy"),"w").close()
    write_plan("deploy.release", f"rm -rf {new_release}")
    if args.canary.lower() in ("true","1","yes"):
        # deploy to canary place
        canary_dir=os.path.join(DEPLOY,"canary")
        if os.path.exists(canary_dir):
            shutil.rmtree(canary_dir)
        shutil.copytree(new_release, canary_dir)
        audit(f"deployed canary to {canary_dir}")
        ok=health_check(canary_dir)
        audit(f"canary health={ok}")
        if not ok:
            # rollback
            audit("canary failed, rolling back (removing canary)")
            shutil.rmtree(canary_dir, ignore_errors=True)
            print(json.dumps({"status":"canary_failed","release":new_release}))
            sys.exit(2)
        # promote to current
    current_link=os.path.join(DEPLOY,"current")
    prev=None
    if os.path.islink(current_link):
        prev=os.readlink(current_link)
    if os.path.exists(current_link):
        try:
            os.remove(current_link)
        except:
            pass
    os.symlink(new_release, current_link)
    audit(f"promoted {new_release} to current (previous={prev})")
    write_plan("deploy.promote", f"rm -rf {new_release} && ln -sf {prev} {current_link} || true")
    print(json.dumps({"status":"ok","release":new_release,"previous":prev}))
