#!/usr/bin/env bash
# new-adr — create a numbered Architecture Decision Record under docs/adr/
# Usage: ./new-adr.sh "Title of the decision"

set -e

ADR_DIR="docs/adr"
LOCKDIR="$ADR_DIR/.new-adr.lock"

TITLE="$1"
if [ -z "$TITLE" ]; then
  echo "Usage: $0 \"Title of the decision\""
  exit 1
fi

mkdir -p "$ADR_DIR"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
  echo "Another new-adr is running, or a stale lock exists at $LOCKDIR" >&2
  echo "Wait for the other run to finish, or remove that directory if a run crashed." >&2
  exit 1
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT INT TERM HUP

# Max numeric prefix among files named like 0007-foo.md or 10000-bar.md (ignores template.md, etc.)
LAST=$(ls -1 "$ADR_DIR" 2>/dev/null | grep -E '^[0-9]+-' | sed 's/-.*//' | sort -n | tail -1)
if [ -z "$LAST" ]; then
  NEXT_NUM=1
else
  NEXT_NUM=$((10#$LAST + 1))
fi

# ASCII-only slug (matches PowerShell); strips Unicode letters to separators
SLUG=$(export LC_ALL=C; printf '%s' "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/-$//')
if [ -z "$SLUG" ]; then
  SLUG="untitled"
fi

NEXT=$(printf '%04d' "$NEXT_NUM")
FILENAME="$ADR_DIR/$NEXT-$SLUG.md"
while [ -e "$FILENAME" ]; do
  NEXT_NUM=$((NEXT_NUM + 1))
  if [ "$NEXT_NUM" -gt 999999 ]; then
    echo "Could not find a free ADR number below 1000000." >&2
    exit 1
  fi
  NEXT=$(printf '%04d' "$NEXT_NUM")
  FILENAME="$ADR_DIR/$NEXT-$SLUG.md"
done

DATE=$(date +%Y-%m-%d)

cat > "$FILENAME" << EOF
# ADR-$NEXT: $TITLE

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-XXX}

## Date

$DATE

## Context

What is the situation? What forces are at play? What constraints exist?
Write this for someone who has zero context on the problem. Because in
18 months, that someone is you.

## Decision

What did we decide? Be specific. Name the technology, the pattern, the
approach. Don't hedge.

## Consequences

What becomes easier? What becomes harder? What are we explicitly accepting
as tradeoffs? What doors does this close?

## Options Considered

### Option A: {Name}
- How it works
- Pros
- Cons
- Why we didn't choose it

### Option B: {Name}
- How it works
- Pros
- Cons
- Why we didn't choose it

### Option C: {Chosen} ✓
- How it works
- Pros
- Cons
- Why we chose it
EOF

echo "Created: $FILENAME"
