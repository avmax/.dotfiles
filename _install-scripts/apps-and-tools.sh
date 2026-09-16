#!/usr/bin/env bash
#
# Running this installs whatever is missing from the two lists below. Anything
# already installed is skipped, however it got there.
#
# Developer tools
#
#   Homebrew             the installer from brew.sh
#   node, npm, npx       Homebrew  node
#   python3, pip3        Homebrew  python
#   PostgreSQL 18        Homebrew  postgresql@18, psql & co. linked onto PATH
#   Docker               Homebrew Cask  docker-desktop (Docker Desktop, with
#                        docker and docker compose)
#
# Desktop apps
#
#   iTerm2               Homebrew Cask  iterm2
#   Google Chrome        Homebrew Cask  google-chrome
#   Visual Studio Code   Homebrew Cask  visual-studio-code
#   Firefox              Homebrew Cask  firefox
#   Telegram             Homebrew Cask  telegram
#   AmneziaVPN           Homebrew Cask  amneziavpn
#   WireGuard            Mac App Store, with mas — its only macOS release
#   mas                  Homebrew, the App Store command line; only when
#                        WireGuard is missing and mas isn't installed yet
#
# A tool counts as installed when its commands are on PATH (macOS's own
# /usr/bin/python3 and pip3 don't count). PostgreSQL also counts when Homebrew
# already has some postgresql@N or Postgres.app is there, and Docker when
# Docker.app is. An app counts when it's in /Applications or ~/Applications.
#
# Neither PostgreSQL nor Docker is started. `brew services start postgresql@18`
# runs PostgreSQL now and at every login. Open Docker once to accept its terms
# and start its engine; `docker compose` only works after that. If mas can't
# install WireGuard, its App Store page opens instead.
#
# The Homebrew installer, the AmneziaVPN and Docker Desktop installs, and mas
# ask for your password. WireGuard needs an Apple Account signed in to the App
# Store.
#
# Safe to run repeatedly. Preview without touching anything:
#   DRY_RUN=1 ./_install-scripts/apps-and-tools.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"

HOMEBREW_INSTALLER=https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
POSTGRES=postgresql@18
WIREGUARD_APP_STORE_ID=1451685025

# Things that are still not installed, as "A, B" — reported at the end.
MISSING=""

# missing <name> — note something that didn't get installed.
missing() { MISSING="${MISSING:+$MISSING, }$1"; }

# find_brew — true if brew can run. Homebrew on Apple Silicon isn't on the
# default PATH; zsh/zprofile adds it, but this may run before that's set up,
# or right after Homebrew itself was installed.
find_brew() {
	if ! command -v brew >/dev/null 2>&1 && [ -x /opt/homebrew/bin/brew ]; then
		PATH="/opt/homebrew/bin:$PATH"
	fi
	command -v brew >/dev/null 2>&1
}

# on_path <command>... — true if every command is on PATH outside /usr/bin,
# which is where macOS keeps its own python3 and pip3.
on_path() {
	local cmd file found
	for cmd in "$@"; do
		found=0
		while IFS= read -r file; do
			case "$file" in /usr/bin/*) ;; *) found=1 ;; esac
		done < <(type -ap "$cmd")
		[ "$found" = 1 ] || return 1
	done
}

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

# brew_has_postgres — true if Homebrew already has some postgresql@N. Those
# formulae are keg-only, so one can be installed without psql being on PATH.
brew_has_postgres() {
	local keg
	[ -n "$BREW_PREFIX" ] || return 1
	for keg in "$BREW_PREFIX"/opt/postgresql@*; do
		[ -e "$keg" ] && return 0
	done
	return 1
}

# install_tool <formula> <command>... — brew install the formula unless all
# its commands are already on PATH, then check that they are.
install_tool() {
	local formula="$1"
	shift

	if on_path "$@"; then
		ok "already installed: $formula ($*)"
		return 0
	fi

	info "installing $formula ($*)"
	if ! run brew install "$formula"; then
		warn "failed: brew install $formula"
		missing "$formula"
	elif [ "$DRY_RUN" != "1" ]; then
		if on_path "$@"; then
			ok "installed $formula ($*)"
		else
			warn "brew install $formula finished, but $* isn't all on PATH"
			missing "$formula"
		fi
	fi
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
		missing "${app%.app}"
	elif [ "$DRY_RUN" != "1" ]; then
		if path="$(app_path "$app")"; then
			ok "installed $(pretty "$path")"
		else
			warn "$* finished, but there is no $app in /Applications"
			missing "${app%.app}"
		fi
	fi
}

# --- developer tools ----------------------------------------------------------

if find_brew; then
	ok "already installed: Homebrew"
else
	info "installing Homebrew"
	if [ "$DRY_RUN" = "1" ]; then
		run /bin/bash -c "\$(curl -fsSL $HOMEBREW_INSTALLER)"
	else
		installer="$(curl -fsSL "$HOMEBREW_INSTALLER")" \
			|| fail "could not download the Homebrew installer — check the network and re-run"
		/bin/bash -c "$installer" || fail "the Homebrew installer failed — see above"
		find_brew || fail "the Homebrew installer finished, but brew isn't there"
		ok "installed Homebrew"
		info "skip Homebrew's \"Next steps\": zsh/zprofile puts brew on PATH (./install.sh zsh)"
	fi
fi

BREW_PREFIX=""
if command -v brew >/dev/null 2>&1; then
	BREW_PREFIX="$(brew --prefix)"
	if [ ! -O "$BREW_PREFIX" ]; then
		warn "Homebrew in $BREW_PREFIX belongs to $(stat -f %Su "$BREW_PREFIX"), so brew install fails for you." \
			"Fix: \"Homebrew owned by another account\" in zsh/install.md"
	fi
fi

install_tool node   node npm npx
install_tool python python3 pip3

if on_path psql || brew_has_postgres || app_path "Postgres.app" >/dev/null; then
	ok "already installed: PostgreSQL"
else
	info "installing PostgreSQL ($POSTGRES)"
	# Keg-only, like every versioned formula: link psql and the rest onto PATH.
	if ! run brew install "$POSTGRES"; then
		warn "failed: brew install $POSTGRES"
		missing PostgreSQL
	elif ! run brew link --force "$POSTGRES"; then
		warn "failed: brew link --force $POSTGRES"
		missing PostgreSQL
	elif [ "$DRY_RUN" != "1" ]; then
		if on_path psql; then
			ok "installed $POSTGRES"
			info "not started — to run it now and at every login: brew services start $POSTGRES"
		else
			warn "brew installed $POSTGRES, but psql isn't on PATH"
			missing PostgreSQL
		fi
	fi
fi

# Docker Desktop, unless Docker.app is already there or docker comes from
# something else, such as OrbStack or Colima — the cask's own docker would
# clash with it.
if docker_app="$(app_path "Docker.app")"; then
	ok "already installed: $(pretty "$docker_app")"
elif on_path docker; then
	ok "already installed: docker ($(pretty "$(command -v docker)"))"
else
	install_app "Docker.app" brew install --cask docker-desktop
	if [ "$DRY_RUN" != "1" ] && app_path "Docker.app" >/dev/null; then
		info "not started — open Docker once to accept its terms and start the engine; docker compose works after that"
	fi
fi

# --- desktop apps -------------------------------------------------------------

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
ok "developer tools and desktop apps installed"
