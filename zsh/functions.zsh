# Shell functions.

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
