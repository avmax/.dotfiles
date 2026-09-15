#!/usr/bin/env bash
#
# Shared helpers for the per-topic installers in this directory.
# Source it, don't execute it:
#
#   . "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
#
# Contract for every installer that uses this:
#   - idempotent: running it twice changes nothing the second time
#   - non-destructive: anything it would overwrite is moved to a backup dir
#   - honours DRY_RUN=1 to print what it would do without doing it

set -euo pipefail

# Repo root, resolved from this file's location — so the repo works from any
# path, not just ~/.dotfiles.
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
export DOTFILES_ROOT

BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
export BACKUP_DIR

DRY_RUN="${DRY_RUN:-0}"

# Set to 1 by link_file the first time something is actually moved aside.
_DOTFILES_DID_BACKUP=0

if [ -t 1 ]; then
	_C_BLUE=$'\033[0;34m'; _C_GREEN=$'\033[0;32m'; _C_YELLOW=$'\033[0;33m'
	_C_RED=$'\033[0;31m';  _C_GREY=$'\033[0;90m';  _C_OFF=$'\033[0m'
else
	_C_BLUE=; _C_GREEN=; _C_YELLOW=; _C_RED=; _C_GREY=; _C_OFF=
fi

info() { printf '%s  ..%s %s\n' "$_C_BLUE"   "$_C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$_C_GREEN"  "$_C_OFF" "$*"; }
warn() { printf '%swarn%s %s\n' "$_C_YELLOW" "$_C_OFF" "$*" >&2; }
fail() { printf '%sfail%s %s\n' "$_C_RED"    "$_C_OFF" "$*" >&2; exit 1; }

# pretty <path> — shorten $HOME to ~ for readable output. The tilde goes in
# through a variable: a literal ~ is tilde-expanded back into $HOME, and the
# escaped \~ form prints its backslash on macOS's bash 3.2.
pretty() { local tilde='~'; printf '%s' "${1/#"$HOME"/$tilde}"; }

# run <cmd> [args...] — executes, or just prints under DRY_RUN=1.
run() {
	if [ "$DRY_RUN" = "1" ]; then
		printf '%s dry%s %s\n' "$_C_GREY" "$_C_OFF" "$*"
	else
		"$@"
	fi
}

# backup_path <path> — move a file, directory or symlink into $BACKUP_DIR.
# Does nothing if the path doesn't exist. This is how installers retire
# anything: nothing is ever deleted.
backup_path() {
	local target="$1"

	[ -e "$target" ] || [ -L "$target" ] || return 0

	if [ "$_DOTFILES_DID_BACKUP" = "0" ]; then
		run mkdir -p "$BACKUP_DIR"
		_DOTFILES_DID_BACKUP=1
	fi
	info "backing up $(pretty "$target") -> $(pretty "$BACKUP_DIR")/"
	run mv "$target" "$BACKUP_DIR/$(basename "$target")"
}

# link_file <source-in-repo> <target-path>
#
# Creates target as a symlink to source. If target already exists it is moved
# into $BACKUP_DIR first — never deleted. If target is already the right
# symlink, does nothing.
link_file() {
	local src="$1" dst="$2"

	[ -e "$src" ] || fail "source does not exist: $src"

	if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
		ok "already linked: $(pretty "$dst")"
		return 0
	fi

	backup_path "$dst"

	run mkdir -p "$(dirname "$dst")"
	run ln -sfn "$src" "$dst"
	ok "linked $(pretty "$dst") -> $(pretty "$src")"
}

# copy_once <source> <target> — copy only if target is absent. Used for
# files the user is meant to edit (local overrides), which must not be
# symlinks into the repo.
copy_once() {
	local src="$1" dst="$2"

	if [ -e "$dst" ]; then
		ok "kept existing $(pretty "$dst")"
		return 0
	fi

	[ -e "$src" ] || fail "source does not exist: $src"
	run mkdir -p "$(dirname "$dst")"
	run cp "$src" "$dst"
	ok "created $(pretty "$dst") (edit it for machine-specific settings)"
}

# version_ge <have> <want> — true if have >= want, dotted numeric compare.
version_ge() {
	[ "$(printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -n1)" = "$2" ]
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "$1 not found. ${2:-Install it and re-run.}"
}

summary() {
	echo
	if [ "$DRY_RUN" = "1" ]; then
		info "dry run — nothing was changed"
	elif [ "$_DOTFILES_DID_BACKUP" = "1" ]; then
		info "replaced files were backed up to $(pretty "$BACKUP_DIR")"
	fi
}
