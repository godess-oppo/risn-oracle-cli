#!/usr/bin/env python3
"""
Agent: Analytics
- Performs simple forecasting & drift detection.
- If drift is detected, writes retrain trigger file.
"""
import os,sys,json,argparse,time,random
import statistics
HOME=os.environ.get("HOME")
RISN_HOME=f"{HOME}/risn-cli"
ANALYTICS=f"{RISN_HOME}/analytics"
ACTIONS=f"{RISN_HOME}/actions"
AUDIT=f"{RISN_HOME}/audit.log"

def audit(msg):
    print(f"[ANALYTICS] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"analytics","msg":msg})+"\n")

def write_plan(name, rollback):
    fname=os.path.join(ACTIONS,f"plan-{int(time.time())}-{name}.json")
    with open(fname,"w") as f:
        json.dump({"name":name,"rollback":rollback,"time":time.time()},f,indent=2)
    audit(f"wrote plan {fname}")

def forecast(days, series):
    # naive forecast: repeat mean
    mu = statistics.mean(series) if series else 0
    return [mu for _ in range(days)]

def detect_drift(series):
    # compare last 7 to previous 30
    if len(series) < 10: return False,0
    last = series[-7:]
    prev = series[-37:-7] if len(series) >= 37 else series[:-7]
    if not prev: return False,0
    mu_prev = sum(prev)/len(prev)
    mu_last = sum(last)/len(last)
    drift = (mu_prev - mu_last)/max(1,mu_prev)
    return abs(drift) > 0.25, drift

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--forecast", type=int, default=14)
    args=p.parse_args()
    audit(f"analytics started forecast={args.forecast}")
    # simulate recent sales series
    series=[max(0,int(100 + random.gauss(0,15) - (time.time()%10))) for _ in range(60)]
    drift,delta = detect_drift(series)
    fcast = forecast(args.forecast, series)
    out={"forecast":fcast,"drift":drift,"delta":delta}
    audit(f"forecast generated drift={drift} delta={delta}")
    if drift:
        trigger_file=os.path.join(RISN_HOME,".retrain_trigger_"+str(int(time.time())))
        open(trigger_file,"w").close()
        audit(f"drift detected -> wrote retrain trigger {trigger_file}")
        write_plan("analytics.drift", f"rm -f {trigger_file}")
    print(json.dumps(out))
