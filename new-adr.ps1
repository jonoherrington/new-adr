# new-adr — create a numbered Architecture Decision Record under docs/adr/
# Usage: .\new-adr.ps1 "Title of the decision"

$ErrorActionPreference = 'Stop'

$ADR_DIR = "docs/adr"

if (-not $args[0]) {
    Write-Host "Usage: .\new-adr.ps1 `"Title of the decision`""
    exit 1
}

$TITLE = $args[0]

function Get-AdrSlug([string]$t) {
    $parts = foreach ($ch in $t.ToLowerInvariant().ToCharArray()) {
        if (($ch -ge 'a' -and $ch -le 'z') -or ($ch -ge '0' -and $ch -le '9')) {
            [string]$ch
        } else {
            '-'
        }
    }
    $s = -join $parts
    $s = [regex]::Replace($s, '-+', '-').TrimEnd('-')
    if ([string]::IsNullOrWhiteSpace($s)) { return 'untitled' }
    return $s
}

if (-not (Test-Path $ADR_DIR)) {
    New-Item -ItemType Directory -Path $ADR_DIR -Force | Out-Null
}

$lockPath = Join-Path $ADR_DIR '.new-adr.lock'
$gotLock = $false
try {
    try {
        $null = New-Item -ItemType Directory -Path $lockPath -ErrorAction Stop
        $gotLock = $true
    } catch {
        Write-Host "Another new-adr is running, or a stale lock exists at $lockPath"
        Write-Host "Wait for the other run to finish, or remove that directory if a prior run crashed."
        exit 1
    }

    $nums = @(Get-ChildItem -Path $ADR_DIR -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            if ($_.Name -match '^(\d+)-') { [int]$matches[1] }
        })
    $LAST = $nums | Sort-Object -Descending | Select-Object -First 1

    $NEXT_NUM = if ($null -eq $LAST) { 1 } else { $LAST + 1 }
    $SLUG = Get-AdrSlug $TITLE

    do {
        $NEXT = '{0:D4}' -f $NEXT_NUM
        $FILENAME = Join-Path $ADR_DIR "$NEXT-$SLUG.md"
        if (-not (Test-Path $FILENAME)) { break }
        $NEXT_NUM++
        if ($NEXT_NUM -gt 999999) {
            Write-Error 'Could not find a free ADR number below 1000000.'
            exit 1
        }
    } while ($true)

    $DATE = Get-Date -Format 'yyyy-MM-dd'

    @"

# ADR-${NEXT}: $TITLE

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

### Option C: {Chosen} $([char]0x2713)
- How it works
- Pros
- Cons
- Why we chose it
"@ | Set-Content -Path $FILENAME -Encoding utf8

    Write-Host "Created: $FILENAME"
} finally {
    if ($gotLock) {
        Remove-Item -Path $lockPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
