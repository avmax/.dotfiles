#!/usr/bin/env bash
#
# Capture this Mac's iTerm2 settings into iTerm/com.googlecode.iterm2.plist —
# the file _install-scripts/iTerm.sh applies on another Mac.
#
#   ./iTerm/export.sh            # update the file, then review with git diff
#   DRY_RUN=1 ./iTerm/export.sh  # say what would change, write nothing
#
# Everything in the com.googlecode.iterm2 defaults domain is kept except the
# machine-local state listed in the filter below: window positions, and the
# keys iTerm2 itself marks as "do not sync". Keys are written sorted, as XML,
# so the same settings always produce the same file and diffs stay readable.
#
# iTerm2 may be running — it writes settings as you change them, into the same
# defaults database this reads.

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"

DOMAIN=com.googlecode.iterm2
PLIST="$DOTFILES_ROOT/iTerm/$DOMAIN.plist"

# Keys that describe this Mac rather than the settings, dropped on the way in.
# Read a plist on stdin, write the filtered one to $1, report on stdout.
FILTER=$(cat <<'PY'
import plistlib, sys

SKIP_PREFIXES = (
    "NoSync",                     # iTerm2's own marker for machine-local state
    "NSWindow Frame ",            # window positions, for this Mac's screens
    "NSSplitView Subview Frames",
    "NSToolbar Configuration",
    "NSNavPanel",
)
SKIP_KEYS = {
    "SUFeedURL",                  # the update feed, with a per-install shard
    "SUFeedAlternateAppNameKey",
    "SUHasLaunchedBefore",
    "SULastCheckTime",
    "SUUpdateRelaunchingMarker",
    "iTerm Version",              # the build that last wrote these settings
    "findMode_iTerm",             # the search mode last used in the find bar
}

prefs = plistlib.loads(sys.stdin.buffer.read())
kept = {
    key: value
    for key, value in prefs.items()
    if key not in SKIP_KEYS and not key.startswith(SKIP_PREFIXES)
}

with open(sys.argv[1], "wb") as out:
    plistlib.dump(kept, out, sort_keys=True)

print(f"kept {len(kept)} settings, dropped {len(prefs) - len(kept)} machine-local keys")
PY
)

require_cmd python3 "macOS installs it with the Command Line Tools: xcode-select --install"

defaults read "$DOMAIN" >/dev/null 2>&1 \
	|| fail "this Mac has no iTerm2 settings to export — install iTerm2 and start it once first"

tmp="$(mktemp -t iterm-prefs)"
trap 'rm -f "$tmp"' EXIT

info "reading the $DOMAIN defaults domain"
ok "$(defaults export "$DOMAIN" - | python3 -c "$FILTER" "$tmp")"

# plutil parses it the way iTerm2's own reader will, before it replaces a file
# that is known to be good.
plutil -lint "$tmp" >/dev/null || fail "the exported settings are not a valid plist"

if [ -f "$PLIST" ] && cmp -s "$tmp" "$PLIST"; then
	ok "no change: $(pretty "$PLIST") already matches this Mac"
elif [ "$DRY_RUN" = "1" ]; then
	run cp "$tmp" "$PLIST"
	info "it would differ from the committed file:"
	diff <(plutil -p "$PLIST" 2>/dev/null || true) <(plutil -p "$tmp") || true
else
	cp "$tmp" "$PLIST"
	chmod 644 "$PLIST"   # mktemp makes the temp file private; this is a repo file
	ok "wrote $(pretty "$PLIST")"
	info "review it with: git diff -- iTerm/"
fi

summary
