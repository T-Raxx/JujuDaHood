#!/usr/bin/env bash
# JujuDaHood build: regenera el manifiesto ADDANS de loader.lua desde addons/*.luau
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

names=()
for f in addons/*.luau; do
  [ -e "$f" ] || continue
  b="$(basename "$f" .luau)"
  names+=("$b")
done

python - "$HERE" "${names[@]}" <<'PY'
import sys, re, os
here = sys.argv[1]; names = sys.argv[2:]
block = "local ADDONS = {\n" + "".join(f'    "{n}",\n' for n in names) + "}"
for fn in ("loader.lua", "install.lua"):
    p = os.path.join(here, fn)
    if not os.path.exists(p): continue
    src = open(p, encoding='utf-8').read()
    src = re.sub(r'local ADDONS = \{.*?\n\}', block, src, count=1, flags=re.S)
    open(p, 'w', encoding='utf-8', newline='\n').write(src)
print(f"manifest: {len(names)} addon(s): " + ", ".join(names) if names else "manifest: (sin addons todavía)")
PY
echo "build ok"
