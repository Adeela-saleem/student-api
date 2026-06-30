#!/usr/bin/env bash
#
# sync.sh — vendors org-framework into a consumer repo's .framework/ folder.
#
# Implementation note (flagged, not yet formally re-confirmed per the
# handoff's open item): this is written as a POSIX-compatible bash
# script, since that's the default assumption for a repo-management
# script and requires no extra runtime beyond git + bash. If the team
# needs first-class Windows support without WSL/Git Bash, a .js (Node)
# or .py (Python) equivalent implementing the same four steps below
# (fetch → strip .git → copy into .framework/ → stamp VERSION) is a
# straightforward port — ask if you want that variant generated
# instead of, or alongside, this one.
#
# Usage:
#   ./sync.sh [--repo <git-url>] [--branch <branch>] [--ref <commit-sha>] [--yes]
#
#   --repo    Git URL of the central org-framework repo.
#             Defaults to $ORG_FRAMEWORK_REPO if set.
#   --branch  Branch to sync from. Defaults to "main".
#   --ref     Exact commit SHA to pin to, instead of a branch's latest.
#             If set, takes priority over --branch.
#   --yes     Skip the overwrite confirmation prompt (for CI use).
#
# What it does:
#   1. Fetches the central org-framework repo at the requested
#      branch/ref into a temporary directory.
#   2. Strips the fetched copy's own .git history — the consumer repo
#      tracks .framework/ as plain committed files, not as a nested
#      git repo or submodule.
#   3. Replaces this repo's .framework/ directory with the fetched
#      contents.
#   4. Writes .framework/VERSION with the exact commit SHA and the
#      sync timestamp, for traceability.
#
# This script does NOT commit the result — review the diff under
# .framework/ and commit it yourself, the same as any other change.

set -euo pipefail

# ---- Defaults -----------------------------------------------------------

REPO_URL="${ORG_FRAMEWORK_REPO:-}"
BRANCH="main"
REF=""
ASSUME_YES="false"
TARGET_DIR=".framework"

# ---- Argument parsing ----------------------------------------------------

usage() {
  sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_URL="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --ref)
      REF="$2"
      shift 2
      ;;
    --yes|-y)
      ASSUME_YES="true"
      shift
      ;;
    -h|--help)
      usage 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage 1
      ;;
  esac
done

if [[ -z "$REPO_URL" ]]; then
  echo "Error: no repo URL given." >&2
  echo "Pass --repo <git-url>, or set \$ORG_FRAMEWORK_REPO." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required and was not found on PATH." >&2
  exit 1
fi

# ---- Confirm we're at a repo root, not buried in a subdirectory --------

if [[ ! -d ".git" ]]; then
  echo "Warning: no .git directory found in the current working" >&2
  echo "directory. sync.sh should normally be run from the root of" >&2
  echo "the consumer repo." >&2
  if [[ "$ASSUME_YES" != "true" ]]; then
    read -r -p "Continue anyway? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  fi
fi

# ---- Overwrite confirmation ---------------------------------------------

if [[ -d "$TARGET_DIR" && "$ASSUME_YES" != "true" ]]; then
  echo "This will replace the existing contents of '$TARGET_DIR/' with"
  echo "a fresh copy from the central framework repo."
  read -r -p "Continue? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

# ---- Fetch into a temp directory ----------------------------------------

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Fetching framework from: $REPO_URL"

if [[ -n "$REF" ]]; then
  echo "Pinning to commit: $REF"
  git clone --quiet "$REPO_URL" "$TMP_DIR"
  git -C "$TMP_DIR" checkout --quiet "$REF"
else
  echo "Using branch: $BRANCH"
  git clone --quiet --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
fi

SYNCED_SHA="$(git -C "$TMP_DIR" rev-parse HEAD)"
SYNCED_SHORT_SHA="$(git -C "$TMP_DIR" rev-parse --short HEAD)"

# Strip the fetched copy's own git history — it's vendored as plain
# files in the consumer repo, never as a nested repo.
rm -rf "$TMP_DIR/.git"

# If the source repo declares its own version (e.g. a top-level
# VERSION or a tag), surface it; otherwise fall back to "unversioned".
SOURCE_VERSION="unversioned"
if [[ -f "$TMP_DIR/VERSION" ]]; then
  SOURCE_VERSION="$(head -n 1 "$TMP_DIR/VERSION")"
fi

# ---- Replace .framework/ -------------------------------------------------

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -R "$TMP_DIR"/. "$TARGET_DIR"/

# ---- Stamp VERSION --------------------------------------------------------

SYNC_TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat > "$TARGET_DIR/VERSION" <<EOF
framework@${SOURCE_VERSION} (commit ${SYNCED_SHA}, synced ${SYNC_TIMESTAMP})
EOF

# ---- Instantiate CLAUDE.md at repo root on first sync only --------------
#
# CLAUDE.md is the thin root pointer file an agent session reads FIRST,
# before .framework/AGENT.md. It must exist at the consumer repo root
# (never inside .framework/), and must never be silently overwritten on
# a resync, since a project may have appended project-specific notes
# below the marker line in templates/CLAUDE.template.md.

CLAUDE_INSTANTIATED="false"
if [[ ! -f "CLAUDE.md" ]]; then
  if [[ -f "$TARGET_DIR/templates/CLAUDE.template.md" ]]; then
    cp "$TARGET_DIR/templates/CLAUDE.template.md" "CLAUDE.md"
    CLAUDE_INSTANTIATED="true"
  fi
fi

echo ""
echo "Synced org-framework into ${TARGET_DIR}/"
echo "  Source:  ${REPO_URL}"
echo "  Ref:     ${SYNCED_SHORT_SHA}"
echo "  Synced:  ${SYNC_TIMESTAMP}"
echo ""

if [[ "$CLAUDE_INSTANTIATED" == "true" ]]; then
  echo "Created CLAUDE.md at the repo root (first sync) — review it before committing."
fi

echo "Next steps:"
echo "  1. Review the diff under ${TARGET_DIR}/ (git diff -- ${TARGET_DIR})."
echo "  2. If this is the first sync, also instantiate PROJECT_KNOWLEDGE.md"
echo "     and DECISIONS.md from ${TARGET_DIR}/templates/ at the repo root,"
echo "     and fill in the mandatory 'stack:' declaration block."
echo "  3. Commit ${TARGET_DIR}/, CLAUDE.md, PROJECT_KNOWLEDGE.md, and"
echo "     DECISIONS.md together — none of these are gitignored."
