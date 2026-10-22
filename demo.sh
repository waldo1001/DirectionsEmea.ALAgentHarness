#!/usr/bin/env bash
# demo.sh - walk the harness one step at a time.
#
#   ./demo.sh list        all steps, current one marked with *
#   ./demo.sh next        one step forward
#   ./demo.sh prev        one step back
#   ./demo.sh goto NN     jump to step NN (00, 01, 02a, 02b, 03 .. 11; 02 = 02a)
#   ./demo.sh reset       stash local edits (recoverable) and go back to step 00
#
# Every step is a branch AND a tag named step-NN-<name> on the same commit.
# Only step tags that are part of main's history count, so stale tags never show up.
set -euo pipefail
cd "$(dirname "$0")"

steps() { git tag -l 'step-*' --merged main | sort; }

current() {
  local b t
  b=$(git branch --show-current)
  if [[ $b == step-* ]]; then echo "$b"; return; fi
  t=$(git tag --points-at HEAD -l 'step-*' | sort | tail -n 1)
  if [[ -n $t ]]; then echo "$t"; return; fi
  echo ""
}

title() { git log -1 --format=%s "refs/tags/$1"; }

go() {
  local name=$1
  if ! git switch --quiet "$name" 2>/dev/null; then
    if [[ -n $(git status --porcelain) ]]; then
      echo "Local changes block the switch. Run ./demo.sh reset (stashes them) or commit them." >&2
      exit 1
    fi
    git switch --quiet --detach "refs/tags/$name"
  fi
  echo "==> $name: $(title "$name")"
}

index_of() {
  local i=0 s
  while read -r s; do
    [[ $s == "$1" ]] && { echo "$i"; return; }
    i=$((i + 1))
  done < <(steps)
  echo -1
}

nth() { steps | sed -n "$(($1 + 1))p"; }

cmd=${1:-list}
case $cmd in
  list)
    cur=$(current)
    while read -r s; do
      mark=" "
      [[ $s == "$cur" ]] && mark="*"
      printf '%s %-30s %s\n' "$mark" "$s" "$(title "$s")"
    done < <(steps)
    ;;
  next | prev)
    cur=$(current)
    if [[ -z $cur ]]; then echo "Not on a step. Use ./demo.sh goto NN." >&2; exit 1; fi
    i=$(index_of "$cur")
    if [[ $cmd == next ]]; then i=$((i + 1)); else i=$((i - 1)); fi
    target=$( ((i >= 0)) && nth "$i" || true)
    if [[ -z $target ]]; then echo "No $cmd step after $cur." >&2; exit 1; fi
    go "$target"
    ;;
  goto)
    nn=${2:?usage: ./demo.sh goto NN}
    suffix=${nn##*[0-9]}; num=${nn%"$suffix"}
    nn=$(printf '%02d' "$((10#$num))")$suffix
    target=$(steps | grep "^step-${nn}[a-z]*-" | head -n 1 || true)
    if [[ -z $target ]]; then echo "No step $nn." >&2; exit 1; fi
    go "$target"
    ;;
  reset)
    if [[ -n $(git status --porcelain) ]]; then
      git stash push --include-untracked --quiet -m "demo.sh reset $(date +%Y-%m-%dT%H:%M:%S)"
      echo "Local edits stashed (git stash list / git stash pop to get them back)."
    fi
    go "$(nth 0)"
    ;;
  *)
    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
