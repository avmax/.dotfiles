#!/usr/bin/env bash
#
# Install the desktop apps, skipping any that are already in /Applications or
# ~/Applications — however they got there:
#
#   Homebrew Cask   iTerm2, Google Chrome, Visual Studio Code, Firefox,
#                   Telegram, AmneziaVPN
#   Mac App Store   WireGuard, with mas (WireGuard for macOS isn't released
#                   anywhere else)
#
# Needs Homebrew, and for WireGuard an Apple Account signed in to the App
# Store. The AmneziaVPN installer and mas ask for your password.
#
# Safe to run repeatedly. Preview without touching anything:
#   DRY_RUN=1 ./install/downloads.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/custom-functions.sh"

WIREGUARD_APP_STORE_ID=1451685025

# Homebrew on Apple Silicon isn't on the default PATH; zsh/zprofile adds it,
# but this may run before that's set up.
if ! command -v brew >/dev/null 2>&1 && [ -x /opt/homebrew/bin/brew ]; then
	PATH="/opt/homebrew/bin:$PATH"
fi
require_cmd brew "Install Homebrew first: https://brew.sh"

# Apps that are still not installed, as "A, B" — reported at the end.
MISSING=""

# app_path <App.app> — print where the app is installed; false if it isn't.
app_path() {
	local dir
	for dir in /Applications "$HOME/Applications"; do
		if [ -d "$dir/$1" ]; then
			printf '%s' "$dir/$1"
			return 0
		fi
	done
	return 1
}

# install_app <App.app> <command> [args...] — run the command unless the app
# is already installed, then check that it landed. brew can't be asked
# instead: it only knows about the apps it installed itself.
install_app() {
	local app="$1" path
	shift

	if path="$(app_path "$app")"; then
		ok "already installed: $(pretty "$path")"
		return 0
	fi

	info "installing ${app%.app}"
	if ! run "$@"; then
		warn "failed: $*"
		MISSING="${MISSING:+$MISSING, }${app%.app}"
	elif [ "$DRY_RUN" != "1" ]; then
		if path="$(app_path "$app")"; then
			ok "installed $(pretty "$path")"
		else
			warn "$* finished, but there is no $app in /Applications"
			MISSING="${MISSING:+$MISSING, }${app%.app}"
		fi
	fi
}

install_app "iTerm.app"              brew install --cask iterm2
install_app "Google Chrome.app"      brew install --cask google-chrome
install_app "Visual Studio Code.app" brew install --cask visual-studio-code
install_app "Firefox.app"            brew install --cask firefox
install_app "Telegram.app"           brew install --cask telegram
install_app "AmneziaVPN.app"         brew install --cask amneziavpn

if ! app_path "WireGuard.app" >/dev/null && ! command -v mas >/dev/null 2>&1; then
	info "installing mas, to get WireGuard from the App Store"
	run brew install mas || warn "could not install mas"
fi
install_app "WireGuard.app" mas get "$WIREGUARD_APP_STORE_ID"

# If mas couldn't install it — no Apple Account signed in, say — hand over to
# the App Store.
if [ "$DRY_RUN" != "1" ] && ! app_path "WireGuard.app" >/dev/null; then
	info "opening WireGuard in the App Store: sign in if asked, then click Get"
	open "macappstore://apps.apple.com/app/id$WIREGUARD_APP_STORE_ID" || true
fi

summary
[ -z "$MISSING" ] || fail "not installed: $MISSING — see the errors above, then re-run"
ok "desktop apps installed"
