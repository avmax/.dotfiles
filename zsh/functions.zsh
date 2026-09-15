# Shell functions.

# up [n] — cd up n directories (default 1)
up() {
  local n=${1:-1}
  [[ $n == <1-> ]] || { print -u2 "usage: up [levels]"; return 1 }
  cd "$(printf '../%.0s' {1..$n})"
}

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

# cls — clear the screen and the scrollback buffer
cls() {
  printf '\e[H\e[2J\e[3J'
}

# tree — rough stand-in until `brew install tree`
(( $+commands[tree] )) || tree() {
  find "${1:-.}" -not -path '*/.git/*' |
    sed -e 's/[^\/]*\//|--/g' -e 's/-- |/    |/g' |
    ${PAGER:-less}
}
