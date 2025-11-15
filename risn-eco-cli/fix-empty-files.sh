#!/bin/bash
echo "🔧 FIXING EMPTY FILES..."

# Count before
before=$(find . -maxdepth 4 -type f -empty | wc -l)
echo "Empty files before: $before"

# Add minimal content to empty files
find . -maxdepth 4 -type f -empty | while read file; do
  case "$file" in
    *.ts|*.js) echo "// Placeholder: $(basename "$file")" > "$file" ;;
    *.json) echo "{}" > "$file" ;;
    *.md) echo "# Placeholder: $(basename "$file")" > "$file" ;;
    *.py) echo "# Placeholder: $(basename "$file")" > "$file" ;;
    *.yaml|*.yml) echo "# Placeholder: $(basename "$file")" > "$file" ;;
    *) echo "# Placeholder: $(basename "$file")" > "$file" ;;
  esac
  echo "✅ Fixed: $file"
done

# Count after
after=$(find . -maxdepth 4 -type f -empty | wc -l)
echo "Empty files after: $after"
echo "🎉 Fixed $((before - after)) empty files!"
