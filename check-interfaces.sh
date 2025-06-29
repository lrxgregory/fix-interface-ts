#!/bin/bash
# Only show interfaces that are NOT clean code:
# - Declared but never used (can be removed)
# - Used/imported in only one file (can be made local)
# - Declared in multiple files (should be centralized)

echo "=== TypeScript interfaces needing attention ==="
echo

# List all exported interfaces (extract just the name)
grep -r -E "export interface [A-Za-z0-9_]+(\s|\{|<|extends)" src/ | sed -E 's/.*export interface ([A-Za-z0-9_]+).*/\1/' | sort | uniq | while read iface; do
  if [[ -z "$iface" ]]; then
    continue
  fi

  # All declaration files (strict match)
  decl_files=$(grep -r --include="*.ts" -E "export interface $iface(\\s|\\{|<|extends)" src/ | cut -d: -f1 | sort | uniq)
  decl_count=$(echo "$decl_files" | grep -c ".")

  if [ "$decl_count" -gt 1 ]; then
    echo "🔸 $iface : declared in multiple files ($decl_count), should be centralized"
    echo "$decl_files" | sed 's/^/    Declared in: /'
    continue
  fi

  # Only one declaration file
  decl_file=$(echo "$decl_files" | head -n1)

  # Import files (strict match, including 'import type', excluding tests/mocks/fixtures and declaration)
  import_files=$(grep -r --include="*.ts" -E "import( type)?[^{]*{[^}]*\b$iface\b[^}]*}" src/ \
    | grep -v ".test.ts" \
    | grep -v "/mocks/" \
    | grep -v "/fixtures/" \
    | grep -v "/__mocks__/" \
    | grep -v "/__fixtures__/" \
    | cut -d: -f1 \
    | grep -v "$decl_file" \
    | sort | uniq)
  # Usage files (strict match, excluding import, declaration, tests/mocks/fixtures)
  usage_files=$(grep -r --include="*.ts" -w "$iface" src/ \
    | grep -v ".test.ts" \
    | grep -v "/mocks/" \
    | grep -v "/fixtures/" \
    | grep -v "/__mocks__/" \
    | grep -v "/__fixtures__/" \
    | grep -v -E "import( type)?[^{]*{[^}]*\b$iface\b[^}]*}" \
    | grep -v -E "export interface $iface(\\s|\\{|<|extends)" \
    | cut -d: -f1 \
    | grep -v "$decl_file" \
    | sort | uniq)

  # Union of import_files and usage_files (unique files)
  all_external_files=$( (echo "$import_files"; echo "$usage_files") | sort | uniq )
  total_external=$(echo "$all_external_files" | grep -c ".")

  if [ "$total_external" -eq 0 ]; then
    # Check if the interface is used in its own file (outside export/import)
    local_usage=$(grep -w "$iface" "$decl_file" | grep -v -E "export interface $iface(\\s|\\{|<|extends)" | grep -v -E "import( type)?[^{]*{[^}]*\b$iface\b[^}]*}" | wc -l)
    if [ "$local_usage" -eq 0 ]; then
      echo "❌ $iface : declared but never used (can be removed)"
      echo "    Declared in: $decl_file"
    fi
  elif [ "$total_external" -eq 1 ]; then
    echo "🔹 $iface : used/imported in only one file (can be made local)"
    echo "    Declared in: $decl_file"
    if [ -n "$import_files" ]; then
      echo "    Imported in:"
      echo "$import_files" | sed 's/^/      → /'
    fi
    if [ -n "$usage_files" ]; then
      echo "    Used in:"
      echo "$usage_files" | sed 's/^/      → /'
    fi
  fi
done
