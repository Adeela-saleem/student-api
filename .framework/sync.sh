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

# ---- Auto-detect stack from project files --------------------------------
#
# Implements AGENT.md Section 4.2: detect first, declared block as fallback.
# Used to pre-fill the stack: block in PROJECT_KNOWLEDGE.md on first sync.

detect_stack() {
  local frontend="none"
  local backend="none"
  local database="none"
  local infra="none"
  local layout="N/A"

  # Frontend detection
  if [[ -f "package.json" ]]; then
    if grep -q '"react"' package.json 2>/dev/null; then
      frontend="react"
    elif grep -q '"vue"' package.json 2>/dev/null; then
      frontend="vue"
    elif grep -q '"next"' package.json 2>/dev/null; then
      frontend="nextjs"
    elif grep -q '"angular"' package.json 2>/dev/null; then
      frontend="angular"
    elif grep -q '"svelte"' package.json 2>/dev/null; then
      frontend="svelte"
    else
      frontend="node-js"
    fi
  fi

  # Backend detection — separate from frontend (may overlap in fullstack)
  if [[ -f "pom.xml" ]]; then
    if grep -q "spring-boot" pom.xml 2>/dev/null; then
      backend="java-spring-boot"
    else
      backend="java-maven"
    fi
  elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    backend="java-gradle"
  elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    if grep -qE "fastapi|FastAPI" requirements.txt pyproject.toml 2>/dev/null; then
      backend="python-fastapi"
    elif grep -qE "django|Django" requirements.txt pyproject.toml 2>/dev/null; then
      backend="python-django"
      layout="Django-style app layout"
    elif grep -qE "flask|Flask" requirements.txt pyproject.toml 2>/dev/null; then
      backend="python-flask"
    else
      backend="python"
    fi
  elif [[ -f "go.mod" ]]; then
    backend="go"
  elif [[ -f "Cargo.toml" ]]; then
    backend="rust"
  elif [[ -f "Gemfile" ]]; then
    if grep -q "rails" Gemfile 2>/dev/null; then
      backend="ruby-on-rails"
    else
      backend="ruby"
    fi
  elif [[ -f "*.csproj" ]] || ls *.csproj 2>/dev/null | grep -q .; then
    backend="dotnet"
  fi

  # Express check runs unconditionally whenever package.json is present and
  # no other backend marker has been found yet. This is intentionally separate
  # from the frontend detection block so that a monorepo package.json containing
  # both a frontend framework (react/vue/etc.) AND express gets backend=node-express
  # rather than backend=none. The [[ "$frontend" == "none" ]] guard that was here
  # before was the bug: it silently skipped express detection the moment any
  # frontend framework was recognised.
  if [[ "$backend" == "none" ]] && [[ -f "package.json" ]]; then
    if grep -q '"express"' package.json 2>/dev/null; then
      backend="node-express"
    else
      # package.json present, no other backend file found, no express —
      # treat as a plain Node project rather than leaving backend blank.
      backend="node-js"
    fi
  fi

  # Database hints from common config files / dependency names
  if grep -qE "postgres|postgresql" requirements.txt pyproject.toml pom.xml package.json go.mod Cargo.toml Gemfile 2>/dev/null; then
    database="postgres"
  elif grep -qE "mysql|mariadb" requirements.txt pyproject.toml pom.xml package.json go.mod Cargo.toml Gemfile 2>/dev/null; then
    database="mysql"
  elif grep -qE "mongo|pymongo" requirements.txt pyproject.toml pom.xml package.json go.mod Cargo.toml Gemfile 2>/dev/null; then
    database="mongodb"
  elif grep -qE "redis" requirements.txt pyproject.toml pom.xml package.json go.mod Cargo.toml Gemfile 2>/dev/null; then
    database="redis"
  elif grep -qE "sqlite" requirements.txt pyproject.toml pom.xml package.json go.mod Cargo.toml Gemfile 2>/dev/null; then
    database="sqlite"
  fi

  # Infra hints
  if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
    infra="docker"
  fi
  if [[ -f "serverless.yml" ]] || [[ -f "serverless.yaml" ]]; then
    infra="serverless"
  fi
  if [[ -f ".vercel" ]] || [[ -f "vercel.json" ]]; then
    infra="vercel"
  fi
  if [[ -f "fly.toml" ]]; then
    infra="fly-io"
  fi

  # Emit as key=value pairs for the caller to consume
  echo "frontend=$frontend"
  echo "backend=$backend"
  echo "database=$database"
  echo "infra=$infra"
  echo "layout=$layout"
}

# ---- Instantiate PROJECT_KNOWLEDGE.md and DECISIONS.md on first sync -----
#
# Like CLAUDE.md, these are only written on first sync — never overwritten —
# since a project may have filled in content. On first sync, we pre-fill
# the stack: block using auto-detection so the file isn't left with bare
# placeholders.

PK_INSTANTIATED="false"
DECISIONS_INSTANTIATED="false"

if [[ ! -f "PROJECT_KNOWLEDGE.md" ]]; then
  if [[ -f "$TARGET_DIR/templates/PROJECT_KNOWLEDGE.template.md" ]]; then

    # Run detection and capture results
    declare -A DETECTED
    while IFS='=' read -r key val; do
      DETECTED[$key]="$val"
    done < <(detect_stack)

    # Write a sed-processed version with detected stack substituted in.
    # Delimiter is '@' — chosen because it cannot appear in any placeholder
    # text (verified: placeholders use only alphanumeric, spaces, |, ., -, ",
    # [], /) and cannot appear in any value detect_stack() can produce
    # (all values are lowercase alphanumeric + hyphens, "none", "unknown",
    # "N/A", or the two known layout strings).
    sed \
      -e "s@\[e\.g\. react-18 | vue-3 | none\]@${DETECTED[frontend]:-none}@g" \
      -e "s@\[e\.g\. python-fastapi | node-express | java-spring-boot | none\]@${DETECTED[backend]:-none}@g" \
      -e "s@\[e\.g\. postgres-15 | mongodb | none\]@${DETECTED[database]:-none}@g" \
      -e "s@\[e\.g\. aws-ecs | vercel | self-hosted-docker\]@${DETECTED[infra]:-unknown}@g" \
      -e "s@\[e\.g\. \"Django-style app layout\" | \"FastAPI-style routers\" | \"N/A\"\]@${DETECTED[layout]:-N/A}@g" \
      "$TARGET_DIR/templates/PROJECT_KNOWLEDGE.template.md" > "PROJECT_KNOWLEDGE.md"

    PK_INSTANTIATED="true"
  fi
fi

if [[ ! -f "DECISIONS.md" ]]; then
  if [[ -f "$TARGET_DIR/templates/DECISIONS.template.md" ]]; then
    cp "$TARGET_DIR/templates/DECISIONS.template.md" "DECISIONS.md"
    DECISIONS_INSTANTIATED="true"
  fi
fi

# ---- Create .claude/commands/ native slash commands (parallel to .framework/commands/) ----
#
# Implements the native CLI slash command layer. .framework/commands/ remains
# unchanged as the source of truth. These are thin wrappers so Claude Code's
# native slash-command picker (the / menu in VS Code extension and terminal)
# discovers the same commands without requiring any tool to read .framework/.
#
# Per AGENT.md Section 5 research: .claude/commands/ is the correct project-
# scoped location. Filename → command name. YAML frontmatter is optional but
# used for description. $ARGUMENTS is available for arguments.

CLAUDE_COMMANDS_CREATED="false"
if [[ -d "$TARGET_DIR/commands" ]]; then
  mkdir -p ".claude/commands"
  for CMD_FILE in "$TARGET_DIR/commands/"*.md; do
    CMD_NAME="$(basename "$CMD_FILE" .md)"
    NATIVE_FILE=".claude/commands/${CMD_NAME}.md"
    # Only create; never overwrite — project may have customized a wrapper
    if [[ ! -f "$NATIVE_FILE" ]]; then
      cat > "$NATIVE_FILE" <<EOF
---
description: org-framework ${CMD_NAME} command — delegates to .framework/commands/${CMD_NAME}.md
---

Read and execute the instructions in \`.framework/commands/${CMD_NAME}.md\`, then proceed as directed there.
\$ARGUMENTS
EOF
      CLAUDE_COMMANDS_CREATED="true"
    fi
  done
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

if [[ "$PK_INSTANTIATED" == "true" ]]; then
  echo "Created PROJECT_KNOWLEDGE.md with auto-detected stack (first sync) — review and adjust before committing."
  echo "  Detected: frontend=${DETECTED[frontend]:-none} | backend=${DETECTED[backend]:-none} | database=${DETECTED[database]:-none} | infra=${DETECTED[infra]:-unknown}"
fi

if [[ "$DECISIONS_INSTANTIATED" == "true" ]]; then
  echo "Created DECISIONS.md from template (first sync)."
fi

if [[ "$CLAUDE_COMMANDS_CREATED" == "true" ]]; then
  echo "Created .claude/commands/ native slash command wrappers — commit alongside .framework/."
fi

echo ""
echo "Next steps:"
echo "  1. Review the diff under ${TARGET_DIR}/ (git diff -- ${TARGET_DIR})."
if [[ "$PK_INSTANTIATED" == "true" ]]; then
  echo "  2. Review auto-detected stack in PROJECT_KNOWLEDGE.md and add any version pins"
  echo "     or layout conventions that file detection can't express."
else
  echo "  2. If PROJECT_KNOWLEDGE.md exists but has a missing/blank stack: block, fill it"
  echo "     in — or let the agent auto-detect and offer to fill it at next session start."
fi
echo "  3. Commit ${TARGET_DIR}/, CLAUDE.md, PROJECT_KNOWLEDGE.md, DECISIONS.md, and"
echo "     .claude/commands/ together — none of these are gitignored."
