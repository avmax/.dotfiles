# Custom functions: every shell function in this repo, in one file.
#
# zsh/zshrc loads it into interactive zsh; the installers in install/ source it
# from bash. Each shell runs only its own part: bash stops at the `return` that
# ends the installer helpers, and zsh skips that block. That keeps the helpers
# out of your terminal (their `set -euo pipefail` would make it exit on the
# first failing command, and `fail` would close the tab) and keeps bash away
# from the zsh syntax further down.
# After editing, check both:
#
#   zsh -n zsh/custom-functions.zsh && DRY_RUN=1 ./install/git.sh
#
# Shell functions (zsh)
#
#   up [n]                 cd up n directories (default 1)
#   mkcddir <dir>          create a directory, with any parents, and cd into it
#   gitroot                cd to the top directory of the current git repository
#   f <text> [dir]         list files containing text; skips .git, node_modules
#   replace <from> <to>    replace literal text in all text files below here
#   extract <archive>...   unpack archives into the current directory
#   tree [dir]             rough directory tree, only if tree isn't installed
#   port [n]               what's listening on TCP port n, or on every port
#   killport <n>           stop what listens on TCP port n: TERM, KILL after 3s
#   nr [script] [args...]  list scripts in the nearest package.json, or run one
#   myip                   local IP of each active interface, then public IP
#   cls                    clear the screen and the scrollback buffer
#   _nr_package_json       path of the nearest package.json (used by nr)
#   _nr                    Tab completion of script names for nr
#
# Installer helpers (bash, only when an install/*.sh script sources this file)
#
#   info <message>            print a progress line
#   ok <message>              print a success line
#   warn <message>            print a warning to stderr
#   fail <message>            print an error to stderr and exit 1
#   pretty <path>             print path with $HOME shortened to ~
#   run <cmd> [args...]       run a command, or only print it under DRY_RUN=1
#   backup_path <path>        move a file, folder or symlink into $BACKUP_DIR
#   link_file <src> <dst>     symlink dst to src, backing up what was there
#   copy_once <src> <dst>     copy src to dst unless dst already exists
#   version_ge <have> <want>  true if version have >= want
#   require_cmd <cmd> [hint]  fail unless cmd is on PATH, with an install hint
#   summary                   end-of-run note: dry run, or where backups went

# --- installer helpers (bash only) --------------------------------------------
#
# Source this from an installer, don't execute it:
#
#   . "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"
#
# Contract for every installer that uses this:
#   - idempotent: running it twice changes nothing the second time
#   - non-destructive: anything it would overwrite is moved to a backup dir
#   - honours DRY_RUN=1 to print what it would do without doing it

if [ -n "${BASH_VERSION:-}" ]; then

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

# bash stops reading here: everything below is zsh-only syntax.
return 0
fi

# --- directories --------------------------------------------------------------

# up [n] — cd up n directories (default 1)
up() {
  local n=${1:-1}
  [[ $n == <1-> ]] || { print -u2 "usage: up [levels]"; return 1 }
  cd "$(printf '../%.0s' {1..$n})"
}

# mkcddir <dir> — create a directory (and any missing parents) and cd into it
mkcddir() {
  (( $# == 1 )) || { print -u2 "usage: mkcddir <dir>"; return 1 }
  mkdir -p -- "$1" && cd -- "$1"
}

# gitroot — cd to the top directory of the current git repository
gitroot() {
  local top
  top=$(git rev-parse --show-toplevel) || return
  cd -- "$top"
}

# --- files --------------------------------------------------------------------

# f <text> [dir] — list files containing text; skips .git, node_modules, binaries
f() {
  (( $# )) || { print -u2 "usage: f <text> [dir]"; return 1 }
  grep -rIl --exclude-dir=.git --exclude-dir=node_modules -- "$1" "${2:-.}"
}

# replace <from> <to> — replace literal text in every text file under the
# current directory (skips .git, node_modules, binaries), then list the files
# it changed. Review with `git diff`.
replace() {
  (( $# == 2 )) || { print -u2 "usage: replace <from> <to>"; return 1 }
  # -F: match the text literally, exactly as the perl below replaces it
  local -a files=(${(0)"$(grep -rIlF --null --exclude-dir=.git --exclude-dir=node_modules -- "$1" .)"})
  (( $#files )) || { print -u2 "replace: no files contain '$1'"; return 1 }
  FROM=$1 TO=$2 perl -pi -e 's/\Q$ENV{FROM}\E/$ENV{TO}/g' -- "${files[@]}"
  print -rl -- "${files[@]}"
}

# extract <archive>... — unpack into the current directory, by extension.
# Carries on past a bad file and returns non-zero at the end.
extract() {
  (( $# )) || { print -u2 "usage: extract <archive>..."; return 1 }
  local file rc=0
  for file in "$@"; do
    if [[ ! -f $file ]]; then
      print -u2 "extract: '$file' is not a file"
      rc=1
      continue
    fi
    case ${file:l} in   # lowercased, so .ZIP and .Z match too
      # macOS tar is libarchive: it reads all of these, compressed or not
      *.tar|*.tar.*|*.tgz|*.tbz|*.tbz2|*.txz|*.tzst|*.zip|*.7z|*.rar|*.xar|*.pkg|*.iso)
                tar -xf "$file" ;;
      *.gz)     gunzip -k "$file" ;;
      *.bz2)    bunzip2 -k "$file" ;;
      *.xz)     unxz -k "$file" ;;                               # needs brew xz
      *.zst)    unzstd -q "$file" ;;                             # needs brew zstd
      *.z)      uncompress -c "$file" > "${file%.?}" ;;
      *)        print -u2 "extract: don't know how to extract '$file'"; false ;;
    esac || rc=1
  done
  return $rc
}

# tree — rough stand-in until `brew install tree`
(( $+commands[tree] )) || tree() {
  find "${1:-.}" -not -path '*/.git/*' |
    sed -e 's/[^\/]*\//|--/g' -e 's/-- |/    |/g' |
    ${PAGER:-less}
}

# --- dev servers and npm ------------------------------------------------------

# port [n] — what's listening on TCP port n, or on every port if none given.
# Shows your own processes; system services need `sudo lsof`.
port() {
  if (( ! $# )); then
    lsof -nP -iTCP -sTCP:LISTEN
    return
  fi
  [[ $1 == <1-65535> ]] || { print -u2 "usage: port [number]"; return 1 }
  lsof -nP -iTCP:$1 -sTCP:LISTEN || { print -u2 "port: nothing of yours is listening on $1"; return 1 }
}

# killport <n> — stop whatever is listening on TCP port n: TERM first, then
# KILL if it's still running 3 seconds later
killport() {
  [[ $1 == <1-65535> ]] || { print -u2 "usage: killport <number>"; return 1 }
  local -aU pids=(${(f)"$(lsof -tiTCP:$1 -sTCP:LISTEN)"})
  (( $#pids )) || { print -u2 "killport: nothing of yours is listening on $1"; return 1 }

  local pid i
  local -a alive
  for pid in $pids; do
    print -r -- "stopping ${$(ps -o comm= -p $pid):t} (pid $pid) on port $1"
  done
  kill $pids 2>/dev/null

  for i in {1..30}; do
    alive=()
    for pid in $pids; do kill -0 $pid 2>/dev/null && alive+=($pid); done
    (( $#alive )) || return 0
    sleep 0.1
  done
  print -u2 "killport: pid $alive ignored TERM, sending KILL"
  kill -KILL $alive 2>/dev/null
}

# nr — list the scripts in the nearest package.json
# nr <script> [args...] — run one with npm: `nr dev`, `nr test -- --watch`
# Tab after `nr` completes script names.
nr() {
  if (( $# )); then
    npm run "$@"
    return
  fi
  local pkg
  pkg=$(_nr_package_json) || return 1
  print -r -- "${(D)pkg}"
  node -e '
    const scripts = require(process.argv[1]).scripts || {};
    const names = Object.keys(scripts);
    if (!names.length) { console.error("nr: no scripts in this package.json"); process.exit(1); }
    const width = Math.max(...names.map(n => n.length));
    for (const n of names) console.log("  " + n.padEnd(width) + "  " + scripts[n]);
  ' "$pkg"
}

# path of the nearest package.json, here or in a parent directory
_nr_package_json() {
  local dir=$PWD
  until [[ -f $dir/package.json ]]; do
    [[ $dir == / ]] && { print -u2 "nr: no package.json here or in any parent directory"; return 1 }
    dir=${dir:h}
  done
  print -r -- "$dir/package.json"
}

# completion for nr: script names, with their commands as descriptions
_nr() {
  local pkg
  pkg=$(_nr_package_json 2>/dev/null) || return 1
  local -a scripts=(${(f)"$(node -e '
    const scripts = require(process.argv[1]).scripts || {};
    for (const [name, cmd] of Object.entries(scripts))
      console.log(name.replace(/:/g, "\\:") + ":" + String(cmd).replace(/\s+/g, " "));
  ' "$pkg" 2>/dev/null)"})
  _describe -t scripts 'npm script' scripts
}
(( $+functions[compdef] )) && compdef _nr nr

# --- network ------------------------------------------------------------------

# myip — local address of every active interface, then the public IP
myip() {
  ifconfig | awk '
    /^[a-z0-9]+:/ { iface = substr($1, 1, length($1) - 1) }
    $1 == "inet" && $2 != "127.0.0.1" {
      tailscale = ($2 ~ /^100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\./) ? "  (tailscale)" : ""
      printf "local   %-15s  %s%s\n", $2, iface, tailscale
    }'
  local public
  if public=$(curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null); then
    print -r -- "public  $public"
  else
    print -u2 "myip: couldn't reach api.ipify.org for the public IP"
    return 1
  fi
}

# --- terminal -----------------------------------------------------------------

# cls — clear the screen and the scrollback buffer
cls() {
  printf '\e[H\e[2J\e[3J'
}
