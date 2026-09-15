#!/usr/bin/env bash
#
# Install the zsh dotfiles.
#
#   ~/.zprofile     -> symlink to <repo>/zsh/zprofile   login shells: PATH, Homebrew
#   ~/.zshrc        -> symlink to <repo>/zsh/zshrc      interactive shells
#   ~/.zshrc.local  -> copy of <repo>/zsh/zshrc.local.example (once, mode 600)
#   ~/.config/starship.toml -> symlink to <repo>/zsh/starship.toml  prompt layout
#
# plus what the config uses:
#
#   plugins    zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions,
#              cloned into ~/.local/share/zsh/plugins and updated on every run
#   starship   the prompt — via Homebrew when this user can write to it,
#              otherwise the official release binary in ~/.local/bin
#
# It also retires the 2019 setup: ~/.oh-my-zsh and stale ~/.zcompdump* files
# move to the backup dir, and ~/.zhistory (where that config wrote history) is
# appended to ~/.zsh_history first.
#
# Safe to run repeatedly. Preview without touching anything:
#   DRY_RUN=1 ./install/zsh.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
BIN_DIR="$HOME/.local/bin"
PLUGINS=(
	zsh-users/zsh-autosuggestions
	zsh-users/zsh-syntax-highlighting
	zsh-users/zsh-completions
)

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

require_cmd zsh "macOS ships it at /bin/zsh."
require_cmd git
require_cmd curl
ok "$(zsh --version)"

# --- retire the oh-my-zsh setup -----------------------------------------------

info "retiring the old setup"
backup_path "$HOME/.oh-my-zsh"
for dump in "$HOME"/.zcompdump*; do
	backup_path "$dump"   # completion now caches in ~/.cache/zsh
done

if [ -f "$HOME/.zhistory" ]; then
	info "appending ~/.zhistory to ~/.zsh_history"
	if [ "$DRY_RUN" = "1" ]; then
		run cat "$HOME/.zhistory" ">>" "$HOME/.zsh_history"
	else
		(umask 077 && cat "$HOME/.zhistory" >> "$HOME/.zsh_history")
	fi
	backup_path "$HOME/.zhistory"
fi

# --- config -------------------------------------------------------------------

info "linking zsh config"
link_file "$DOTFILES_ROOT/zsh/zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_ROOT/zsh/zshrc"    "$HOME/.zshrc"
link_file "$DOTFILES_ROOT/zsh/starship.toml" "$HOME/.config/starship.toml"
copy_once "$DOTFILES_ROOT/zsh/zshrc.local.example" "$HOME/.zshrc.local"
if [ -f "$HOME/.zshrc.local" ]; then
	run chmod 600 "$HOME/.zshrc.local"   # it's where secrets go
fi

# The completion dump is a cache that is only re-checked once a day; clear it
# so fpath changes in the config take effect in the next shell.
for dump in "${XDG_CACHE_HOME:-$HOME/.cache}"/zsh/zcompdump-*; do
	[ -e "$dump" ] && run rm -f "$dump"
done

# --- plugins ------------------------------------------------------------------

info "plugins in $(pretty "$PLUGIN_DIR")"
for repo in "${PLUGINS[@]}"; do
	name="${repo#*/}"
	dest="$PLUGIN_DIR/$name"

	if [ -d "$dest/.git" ]; then
		if [ "$DRY_RUN" = "1" ]; then
			run git -C "$dest" pull --ff-only --quiet
			continue
		fi
		before="$(git -C "$dest" rev-parse --short HEAD)"
		git -C "$dest" pull --ff-only --quiet \
			|| fail "could not update $(pretty "$dest") — local changes? Move it away and re-run."
		after="$(git -C "$dest" rev-parse --short HEAD)"
		if [ "$before" = "$after" ]; then
			ok "up to date: $name ($after)"
		else
			ok "updated $name $before -> $after"
		fi
	else
		backup_path "$dest"   # something that isn't a clone is in the way
		run mkdir -p "$PLUGIN_DIR"
		run git clone --quiet --depth 1 "https://github.com/$repo.git" "$dest"
		ok "cloned $name"
	fi
done

# --- starship -----------------------------------------------------------------

# Official release binary, checked against the .sha256 published beside it.
install_starship_binary() {
	local arch asset url want have

	case "$(uname -m)" in
		arm64)  arch=aarch64 ;;
		x86_64) arch=x86_64 ;;
		*)      fail "no starship build for $(uname -m) — see https://starship.rs" ;;
	esac
	asset="starship-$arch-apple-darwin.tar.gz"
	url="https://github.com/starship/starship/releases/latest/download/$asset"

	if [ "$DRY_RUN" = "1" ]; then
		run curl -fsSL -o "$asset" "$url"
		run install -m 0755 starship "$BIN_DIR/starship"
		return 0
	fi

	curl -fsSL --retry 2 -o "$WORK/$asset" "$url" \
		|| fail "download failed: $url"
	curl -fsSL --retry 2 -o "$WORK/$asset.sha256" "$url.sha256" \
		|| fail "download failed: $url.sha256"

	want="$(awk '{print $1}' "$WORK/$asset.sha256")"
	have="$(shasum -a 256 "$WORK/$asset" | awk '{print $1}')"
	[ "$want" = "$have" ] || fail "checksum mismatch for $asset (expected $want, got $have)"

	tar -xzf "$WORK/$asset" -C "$WORK" starship
	mkdir -p "$BIN_DIR"
	install -m 0755 "$WORK/starship" "$BIN_DIR/starship"
	ok "installed $("$BIN_DIR/starship" --version | head -n1) to $(pretty "$BIN_DIR")"
}

info "starship prompt"
export PATH="$BIN_DIR:$PATH"
if command -v starship >/dev/null 2>&1; then
	ok "already installed: $(starship --version | head -n1) ($(pretty "$(command -v starship)"))"
elif command -v brew >/dev/null 2>&1 && [ -w "$(brew --prefix)" ]; then
	run brew install starship
	ok "installed starship with Homebrew"
else
	if command -v brew >/dev/null 2>&1; then
		warn "$(brew --prefix) is not writable by $(id -un), so Homebrew can't install — using the release binary (see README → zsh → Homebrew)"
	fi
	install_starship_binary
fi

# --- verify -------------------------------------------------------------------

if [ "$DRY_RUN" != "1" ]; then
	info "verifying"

	for file in "$DOTFILES_ROOT"/zsh/zprofile "$DOTFILES_ROOT"/zsh/zshrc "$DOTFILES_ROOT"/zsh/*.zsh; do
		zsh -n "$file" || fail "syntax error in $(pretty "$file")"
	done
	ok "config parses"

	# Start a login + interactive shell the way a new terminal tab does, with a
	# clean environment, and fail on anything it prints to stderr. TERM is
	# pinned to what iTerm / VS Code set, not inherited: this script may itself
	# be running under TERM=dumb, where the prompt is deliberately skipped.
	clean_zsh() {
		env -i HOME="$HOME" USER="${USER:-$(id -un)}" LOGNAME="${LOGNAME:-$(id -un)}" \
			SHELL=/bin/zsh TERM=xterm-256color \
			zsh -lic "$1"
	}

	errors="$(clean_zsh exit 2>&1 >/dev/null)" \
		|| fail "a new zsh exited non-zero:
$errors"
	[ -z "$errors" ] || fail "a new zsh printed errors on startup:
$errors"
	ok "a new shell starts with no errors"

	# shellcheck disable=SC2016  # expanded by zsh, not here
	read -r autosuggest highlight prompt <<<"$(clean_zsh \
		'print ${+functions[_zsh_autosuggest_start]} ${+functions[_zsh_highlight]} ${+functions[prompt_starship_precmd]}' 2>/dev/null)"
	[ "$autosuggest" = 1 ] || fail "zsh-autosuggestions did not load"
	[ "$highlight" = 1 ]   || fail "zsh-syntax-highlighting did not load"
	[ "$prompt" = 1 ]      || fail "starship prompt did not load"
	ok "plugins and starship load"

	# shellcheck disable=SC2016
	read -r comp_git comp_npm <<<"$(clean_zsh 'print ${_comps[git]:--} ${_comps[npm]:--}' 2>/dev/null)"
	[ "$comp_git" != "-" ] || fail "no completion registered for git"
	[ "$comp_npm" != "-" ] || fail "no completion registered for npm"
	ok "completion: git -> $comp_git, npm -> $comp_npm"

	# shellcheck disable=SC2016
	ok "git in new shells: $(clean_zsh 'print -r -- "$(command -v git) ($(git --version))"' 2>/dev/null)"

	case "${SHELL:-}" in
		*/zsh) ok "login shell is zsh ($SHELL)" ;;
		*)     warn "your login shell is ${SHELL:-unknown} — switch with: chsh -s /bin/zsh" ;;
	esac
fi

summary
ok "zsh dotfiles installed — open a new terminal tab to use them"
