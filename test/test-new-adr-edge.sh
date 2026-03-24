#!/usr/bin/env bash
# Run from anywhere: bash test/test-new-adr-edge.sh
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"
BASH="${BASH:-bash}"

fail() { echo "FAIL: $1" >&2; exit 1; }

rm -rf docs/adr
"$BASH" ./new-adr.sh "" && fail "empty title should exit non-zero"
[ ! -d docs/adr ] || fail "empty title should not create docs/adr"

rm -rf docs/adr
"$BASH" ./new-adr.sh "Normal"
[ -f docs/adr/0001-normal.md ] || fail "fresh 0001"

"$BASH" ./new-adr.sh "!!!"
[ -f docs/adr/0002-untitled.md ] || fail "punct-only -> untitled slug"

rm -rf docs/adr
mkdir -p docs/adr
echo x > docs/adr/0005-keep.md
"$BASH" ./new-adr.sh "Six"
[ -f docs/adr/0006-six.md ] || fail "increment after 0005"

rm -rf docs/adr
mkdir -p docs/adr
echo x > docs/adr/0009-a.md
echo x > docs/adr/0010-b.md
"$BASH" ./new-adr.sh "Eleven"
[ -f docs/adr/0011-eleven.md ] || fail "numeric order after 0010"

rm -rf docs/adr
mkdir -p docs/adr
echo x > docs/adr/template.md
"$BASH" ./new-adr.sh "First real"
[ -f docs/adr/0001-first-real.md ] || fail "ignore template.md"

rm -rf docs/adr
mkdir -p docs/adr
echo x > docs/adr/0005-a.md
echo x > docs/adr/0006-six.md
"$BASH" ./new-adr.sh "Six"
[ -f docs/adr/0007-six.md ] || fail "bump when filename collides"

rm -rf docs/adr
mkdir -p docs/adr
echo x > docs/adr/10000-z.md
"$BASH" ./new-adr.sh "Next"
[ -f docs/adr/10001-next.md ] || fail "ADR past 9999"

rm -rf docs/adr
mkdir -p docs/adr/.new-adr.lock
"$BASH" ./new-adr.sh "Locked" && fail "lock should block concurrent run"
rm -rf docs/adr

rm -rf docs/adr
"$BASH" ./new-adr.sh "Hello_World Test"
[ -f docs/adr/0001-hello-world-test.md ] || fail "bash slug"
rm -rf docs/adr

echo "OK bash edge tests"
