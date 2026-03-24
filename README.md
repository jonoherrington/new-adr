# new-adr

Scaffold a new [Architecture Decision Record](https://adr.github.io/) without reaching for another SaaS or a heavyweight generator. You get the next `000N-slug.md` name, today’s date, and a short Nygard-style skeleton you can fill in and land as a PR.

Bash and PowerShell versions do the same work. Pick one. The point is the habit works on macOS, Linux, and Windows without a debate about tooling.

If you want the full template story and where this fits in a real team, read [How to Write Architecture Decision Records That Actually Get Used](https://www.jonoherrington.com/blog/how-to-write-adrs-that-actually-get-used).

## What you get

The scripts look at `docs/adr/`, find the highest numeric prefix on files that look like ADRs, add one, and write a new markdown file. Anything that is not `digits-` at the start of the filename (your `template.md`, lock folder, random notes) stays out of the math. Past `9999` still works.

If the path it wants already exists (someone hand-renumbered, a bad merge, you got creative), it keeps bumping the number until the filename is free. No silent overwrite.

Two terminals in the **same** clone coordinate through `docs/adr/.new-adr.lock`. If a run dies mid-flight, delete that empty directory and run again. This is not distributed locking across two laptops on two branches ... for that you still use your normal PR discipline.

Slugs are ASCII letters and digits only. Unicode in the title becomes hyphens the same way in both scripts so reviews and filenames stay boring and predictable.

No install step. Copy the files into your repo root or into `scripts/` and call them from there.

## Requirements

| Script | What you need |
|--------|----------------|
| `new-adr.sh` | Bash plus `grep`, `sed`, and `date` (macOS, Linux, or [Git for Windows](https://git-scm.com/download/win) Git Bash) |
| `new-adr.ps1` | Windows PowerShell 5.1+ or [PowerShell 7+](https://github.com/PowerShell/PowerShell) |

Run from the **repository root** where you want `docs/adr/` to appear, unless you edit `ADR_DIR` at the top of both files (keep the two scripts aligned if you use both).

## Quick start

Clone or download this repo, copy `new-adr.sh` and/or `new-adr.ps1` into your project. If they live under `scripts/`, call `bash scripts/new-adr.sh "Your title"` instead.

```bash
git clone https://github.com/YOUR_GITHUB_USER/new-adr.git
cd new-adr
chmod +x new-adr.sh
./new-adr.sh "Use Postgres for the orders service"
```

You should see something like:

```text
Created: docs/adr/0001-use-postgres-for-the-orders-service.md
```

Open the file, replace the placeholders, move status from the brace line to something real (`Accepted`, `Proposed`, whatever matches your process), open a PR.

## Usage

**macOS and Linux**

```bash
chmod +x new-adr.sh
./new-adr.sh "Title of the decision"
```

**Windows (Git Bash)**  
PowerShell does not have `chmod` and you do not need an executable bit. From Git Bash:

```bash
bash new-adr.sh "Title of the decision"
```

**Windows (PowerShell)**

```powershell
.\new-adr.ps1 "Title of the decision"
```

If policy blocks scripts, once per user:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Layout

Output goes under **`docs/adr/`** (the folder is created if it is missing).

```text
docs/adr/
  0001-use-postgres-for-the-orders-service.md
  0002-adopt-graphql-for-storefront-api.md
  template.md          # optional; ignored for numbering
```

This repo already ignores `docs/adr/.new-adr.lock/` in `.gitignore`. The lock only exists while a run is in flight.

## Behavior (the details)

**Numbering.** Only basenames matching `^[0-9]+-` count. `template.md` and the lock directory do not.

**Padding.** At least four digits (`0001`, `0010`, `10001`, and so on).

**Empty or punctuation-only title.** Slug becomes `untitled`.

**Stale lock.** If the tool complains about a stale lock, remove the `docs/adr/.new-adr.lock` directory. It is an empty folder used as a mutex.

**Two machines.** Two clones on two machines can still pick the same number. This tool does not fix that. Your branch and PR process does.

**Different folder.** Change `ADR_DIR` at the top of both scripts.

## Development

Test harnesses wipe and recreate `docs/adr/` in the repo root.

```bash
bash test/test-new-adr-edge.sh
```

```powershell
pwsh -File test/test-new-adr-edge.ps1
```

CI is in [.github/workflows/ci.yml](.github/workflows/ci.yml) ... Bash on Ubuntu, PowerShell on Windows, on every push and pull request.

## License

MIT. See [LICENSE](LICENSE).

## Publishing your own GitHub copy

Create an empty repo (for example `new-adr` under your user), then:

```bash
cd /path/to/new-adr
git init
git add .
git commit -m "Initial commit: ADR scaffold scripts"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USER/new-adr.git
git push -u origin main
```

Swap `YOUR_GITHUB_USER` in the clone URL at the top of this file once the remote exists.
