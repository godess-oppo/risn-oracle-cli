#!/bin/bash
echo "🚀 Starting RISN self-healing demo..."

# Simulate issue
echo "🛠️  Creating simulated issue..."
echo '{"error":"API timeout","timestamp":"'$(date -Iseconds)'"}' > risn/audit.log

# Run healing
echo "🔧 Running healing workflow..."
risn ops heal --dry-run

# Show generated plan
echo "📝 Generated action plan:"
cat risn/actions/ops_*.json

echo "✅ Demo complete! Run 'risn ops heal --policy-accept' to execute."
