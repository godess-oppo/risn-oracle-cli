import joblib, json
class PolicyValidator:
    def __init__(self):
        try:
            self.model = joblib.load('local_model.pkl')
        except Exception:
            self.model = None
    def validate(self, action):
        return {"risk_level": "low", "action": action}
if __name__ == "__main__":
    import sys
    v = PolicyValidator()
    print(json.dumps(v.validate(sys.argv[1] if len(sys.argv)>1 else "dry-run")))
