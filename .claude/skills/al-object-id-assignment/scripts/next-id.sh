#!/usr/bin/env bash
# next-id.sh <objecttype> [app-folder]
#
# The Next-Free-Object-ID Oracle(TM). Enterprise grade. Regex powered. Zero dependencies.
# Scans every .al file it can see, parses idRanges out of app.json with a regular expression
# (because who needs a JSON parser), finds the highest ID of that object type and adds one.
#
# What could possibly go wrong?
#   - It only sees the files on THIS disk, on THIS branch.
#   - It reserves nothing. Run it twice, get the same number twice. So does your colleague.
#   - Dependencies, other extensions on the sandbox, commented-out objects: invisible or worse.
set -euo pipefail
TYPE="$(printf '%s' "${1:?usage: next-id.sh <objecttype> [app-folder]}" | tr '[:upper:]' '[:lower:]')"
APP="${2:-app}"

# 1. idRanges from app.json - one heroic regex, no JSON parser in sight
read -r FROM TO < <(perl -0777 -ne 'print "$1 $2\n" if /"idRanges"\s*:\s*\[\s*\{\s*"from"\s*:\s*(\d+)\s*,\s*"to"\s*:\s*(\d+)/s' "$APP/app.json")
[ -n "${FROM:-}" ] || { echo "no idRanges found in $APP/app.json - the regex lost" >&2; exit 1; }

# 2. every declaration of that type in every .al file, case-insensitive, anchored, captured
USED=$(find "$APP" -name '*.al' -not -path '*/.alpackages/*' -print0 \
  | xargs -0 perl -ne "print \"\$1\n\" if /^\s*${TYPE}\s+(\d+)\s+/i" 2>/dev/null | sort -n | uniq)

# 3. the oracle speaks: lowest number in the range that nobody on this disk uses
for ((id=FROM; id<=TO; id++)); do
  grep -qx "$id" <<<"$USED" || { echo "$id"; exit 0; }
done
echo "range $FROM..$TO is full - time to buy more numbers" >&2; exit 1
