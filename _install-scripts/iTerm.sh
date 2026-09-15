#!/usr/bin/env bash
#
# Install the iTerm2 settings.
#
#   iTerm/com.googlecode.iterm2.plist  ->  the com.googlecode.iterm2 defaults domain
#
# The file holds the profiles, the key and mouse bindings and the app-wide
# settings — everything iTerm2 keeps except the window positions and the state
# it marks as machine-local. Importing merges it into the domain: what the file
# sets wins, anything else this Mac has is left alone.
#
# iTerm2 has to be quit first. It keeps its profiles in memory and writes them
# back out when it quits, which would undo the import. A dry run is fine with
# iTerm2 open.
#
# Safe to run repeatedly. The settings being replaced are copied to the backup
# dir first. Preview without touching anything:
#   DRY_RUN=1 ./_install-scripts/iTerm.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"

DOMAIN=com.googlecode.iterm2
PLIST="$DOTFILES_ROOT/iTerm/$DOMAIN.plist"

# Read the settings file given as $1 and describe what is in it.
DESCRIBE=$(cat <<'PY'
import plistlib, sys

prefs = plistlib.load(open(sys.argv[1], "rb"))
profiles = prefs.get("New Bookmarks", [])
default = next(
    (p for p in profiles if p.get("Guid") == prefs.get("Default Bookmark Guid")),
    None,
)

names = ", ".join(p.get("Name", "?") for p in profiles) or "none"
print(f"profiles: {names}")
if default:
    print(f"default profile: {default.get('Name')} — {default.get('Normal Font')}, "
          f"{default.get('Columns')}x{default.get('Rows')}, {default.get('Terminal Type')}")
print(f"bindings: {len(prefs.get('GlobalKeyMap', {}))} key, "
      f"{len(prefs.get('PointerActions', {}))} mouse and trackpad")
PY
)

# Print the fonts the profiles ask for, one per line, without their point size.
FONTS=$(cat <<'PY'
import plistlib, sys

fonts = set()
for profile in plistlib.load(open(sys.argv[1], "rb")).get("New Bookmarks", []):
    keys = ["Normal Font"]
    if profile.get("Use Non-ASCII Font"):
        keys.append("Non Ascii Font")
    for key in keys:
        name = profile.get(key)
        if name:
            fonts.add(name.rsplit(" ", 1)[0])   # "MesloLGS-NF-Regular 13" -> name
print("\n".join(sorted(fonts)))
PY
)

# Compare the settings file given as $1 against the live domain. Only the keys
# the file sets are checked — the import leaves everything else alone, and a
# Mac that has run iTerm2 always has more keys than this.
VERIFY=$(cat <<'PY'
import plistlib, subprocess, sys

want = plistlib.load(open(sys.argv[1], "rb"))
live = plistlib.loads(
    subprocess.run(
        ["defaults", "export", sys.argv[2], "-"], check=True, capture_output=True
    ).stdout
)

missing = sorted(key for key in want if key not in live)
differs = sorted(key for key, value in want.items() if key in live and live[key] != value)
if missing or differs:
    for key in missing:
        print(f"not imported: {key}", file=sys.stderr)
    for key in differs:
        print(f"differs after import: {key}", file=sys.stderr)
    sys.exit(1)
print(f"all {len(want)} settings match the file")
PY
)

# font_installed <name> — true if a font file for this name looks installed.
# Profiles name a font by its PostScript name ("MesloLGS-NF-Regular"); the file
# is named after the family ("MesloLGS NF Regular.ttf"). Only the part before
# the first separator is reliably the same in both, so match on that.
font_installed() {
	local dir
	for dir in "$HOME/Library/Fonts" /Library/Fonts /System/Library/Fonts \
		/System/Library/Fonts/Supplemental; do
		[ -d "$dir" ] || continue
		[ -n "$(find "$dir" -maxdepth 1 -iname "${1%%[- ]*}*" -print -quit)" ] && return 0
	done
	return 1
}

# --- checks -------------------------------------------------------------------

require_cmd python3 "macOS installs it with the Command Line Tools: xcode-select --install"
require_cmd defaults "It is part of macOS, at /usr/bin/defaults."

[ -f "$PLIST" ] || fail "no settings file at $(pretty "$PLIST")"
plutil -lint "$PLIST" >/dev/null || fail "$(pretty "$PLIST") is not a valid plist"
ok "$(pretty "$PLIST")"
python3 -c "$DESCRIBE" "$PLIST" | while IFS= read -r line; do ok "$line"; done

if [ -d /Applications/iTerm.app ] || [ -d "$HOME/Applications/iTerm.app" ]; then
	ok "iTerm2 is installed"
else
	warn "iTerm2 is not installed — the settings are imported anyway and apply" \
		"as soon as it is. Install it with: ./install.sh apps-and-tools"
fi

if pgrep -x iTerm2 >/dev/null 2>&1; then
	if [ "${TERM_PROGRAM:-}" = "iTerm.app" ]; then
		blocked="this is running inside iTerm2, which writes its profiles back out
     when it quits and would undo the import. Open Terminal.app and run it
     there:  cd $(pretty "$DOTFILES_ROOT") && ./install.sh iTerm"
	else
		blocked="iTerm2 is running, and writes its profiles back out when it quits,
     which would undo the import. Quit it with Cmd-Q and re-run."
	fi

	if [ "$DRY_RUN" = "1" ]; then
		warn "a real run would stop here: $blocked"
	else
		fail "$blocked"
	fi
fi

# --- install ------------------------------------------------------------------

# The live settings are cached by cfprefsd, so they are copied out with
# `defaults export` instead of being moved aside with backup_path — moving the
# file would leave the cache holding the old values, and they would come back.
if defaults read "$DOMAIN" >/dev/null 2>&1; then
	info "backing up this Mac's settings -> $(pretty "$BACKUP_DIR")/$DOMAIN.plist"
	run mkdir -p "$BACKUP_DIR"
	run defaults export "$DOMAIN" "$BACKUP_DIR/$DOMAIN.plist"
	_DOTFILES_DID_BACKUP=1   # so summary() says where they went
else
	ok "this Mac has no iTerm2 settings yet — nothing to back up"
fi

info "importing into the $DOMAIN defaults domain"
run defaults import "$DOMAIN" "$PLIST"

# --- verify -------------------------------------------------------------------

if [ "$DRY_RUN" != "1" ]; then
	info "verifying"
	# The check has to run in its own statement: `ok "$(...)"` would report the
	# printf's exit status, not python's, and a failed import would read as fine.
	if ! matched="$(python3 -c "$VERIFY" "$PLIST" "$DOMAIN")"; then
		fail "the import did not take — see the keys listed above"
	fi
	ok "$matched"

	while IFS= read -r font; do
		[ -n "$font" ] || continue
		if font_installed "$font"; then
			ok "font installed: $font"
		else
			warn "the profiles ask for $font, which is not installed on this Mac." \
				"The prompt's icons show as boxes until it is — zsh/install.md," \
				"\"Set up the terminal\", has the four files to download."
		fi
	done <<<"$(python3 -c "$FONTS" "$PLIST")"
fi

summary
ok "iTerm2 settings installed — they apply the next time iTerm2 starts"
