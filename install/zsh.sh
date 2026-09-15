#!/usr/bin/env bash
#
# Install the zsh dotfiles.
#
#   ~/.zprofile     -> symlink to <repo>/zsh/zprofile   login shells: PATH, Homebrew
#   ~/.zshrc        -> symlink to <repo>/zsh/zshrc      interactive shells
#
# ~/.zshrc.local, for machine-specific settings and secrets, is yours to create
# (see zsh/readme.md); if it exists, the installer keeps it private (mode 600).
#
# plus the plugins the config loads, cloned into ~/.local/share/zsh/plugins and
# updated on every run:
#
#   powerlevel10k            the prompt; `p10k configure` writes <repo>/zsh/p10k.zsh
#   zsh-autosuggestions
#   zsh-syntax-highlighting
#   zsh-completions
#
# It also retires earlier setups by moving them to the backup dir — ~/.oh-my-zsh,
# the Starship prompt, stale ~/.zcompdump* files — and appends ~/.zhistory
# (where the 2019 config wrote history) to ~/.zsh_history.
#
# Safe to run repeatedly. Preview without touching anything:
#   DRY_RUN=1 ./install/zsh.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"

PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
PLUGINS=(
	romkatv/powerlevel10k
	zsh-users/zsh-autosuggestions
	zsh-users/zsh-syntax-highlighting
	zsh-users/zsh-completions
)

require_cmd zsh "macOS ships it at /bin/zsh."
require_cmd git
ok "$(zsh --version)"

# --- retire earlier setups ----------------------------------------------------

info "retiring earlier setups"
backup_path "$HOME/.oh-my-zsh"
for dump in "$HOME"/.zcompdump*; do
	backup_path "$dump"   # completion now caches in ~/.cache/zsh
done

# Starship was the prompt before powerlevel10k. Only what this installer put
# there: the config symlink into this repo and the release binary.
starship_link="$HOME/.config/starship.toml"
if [ -L "$starship_link" ] && [[ "$(readlink "$starship_link")" == "$DOTFILES_ROOT"/* ]]; then
	backup_path "$starship_link"
fi
backup_path "$HOME/.local/bin/starship"

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
		# Compare full hashes: --short can grow a digit after a fetch and make
		# the same commit look different.
		before="$(git -C "$dest" rev-parse HEAD)"
		git -C "$dest" pull --ff-only --quiet \
			|| fail "could not update $(pretty "$dest") — local changes? Move it away and re-run."
		after="$(git -C "$dest" rev-parse HEAD)"
		if [ "$before" = "$after" ]; then
			ok "up to date: $name (${after:0:7})"
		else
			ok "updated $name ${before:0:7} -> ${after:0:7}"
		fi
	else
		backup_path "$dest"   # something that isn't a clone is in the way
		run mkdir -p "$PLUGIN_DIR"
		run git clone --quiet --depth 1 "https://github.com/$repo.git" "$dest"
		ok "cloned $name"
	fi
done

# powerlevel10k shows git status through gitstatusd, a small binary it would
# otherwise download the first time a prompt appears inside a git repo.
info "gitstatusd for powerlevel10k"
if [ "$DRY_RUN" = "1" ]; then
	run /bin/sh "$PLUGIN_DIR/powerlevel10k/gitstatus/install"
else
	/bin/sh "$PLUGIN_DIR/powerlevel10k/gitstatus/install" </dev/null >/dev/null \
		|| fail "could not download gitstatusd — check the network and re-run"
	ok "gitstatusd ready in $(pretty "${XDG_CACHE_HOME:-$HOME/.cache}/gitstatus")"
fi

# --- verify -------------------------------------------------------------------

if [ "$DRY_RUN" != "1" ]; then
	info "verifying"

	for file in "$DOTFILES_ROOT"/zsh/zprofile "$DOTFILES_ROOT"/zsh/zshrc "$DOTFILES_ROOT"/zsh/*.zsh; do
		zsh -n "$file" || fail "syntax error in $(pretty "$file")"
	done
	ok "config parses"

	# Start login + interactive shells the way a new terminal tab does, with a
	# clean environment. TERM is pinned to what iTerm / VS Code set rather than
	# inherited, since this script may itself run under TERM=dumb. No prompt is
	# drawn under -c, so the p10k wizard can't start in either variant.
	#
	#   clean_zsh  no terminal, like the `zsh -lic` GUI apps and IDEs run to
	#              read your environment; powerlevel10k is skipped there
	#   tty_zsh    inside a pseudo-terminal via script(1), like a real tab, so
	#              powerlevel10k loads. stdout and stderr arrive merged, and the
	#              terminal echoes script's end of input as "^D" plus two
	#              backspaces; that echo and the CRs are stripped
	zsh_env=(env -i HOME="$HOME" USER="${USER:-$(id -un)}" LOGNAME="${LOGNAME:-$(id -un)}"
		SHELL=/bin/zsh TERM=xterm-256color)
	clean_zsh() { "${zsh_env[@]}" zsh -lic "$1"; }
	tty_zsh()   { script -q /dev/null "${zsh_env[@]}" zsh -lic "$1" </dev/null | sed $'s/\\^D\b\b//g' | tr -d '\r'; }

	errors="$(clean_zsh exit 2>&1 >/dev/null)" \
		|| fail "a new zsh without a terminal exited non-zero:
$errors"
	[ -z "$errors" ] || fail "a new zsh without a terminal printed errors on startup:
$errors"
	errors="$(tty_zsh exit)"
	[ -z "$errors" ] || fail "a new zsh in a terminal printed this on startup:
$errors"
	ok "a new shell starts silently, with and without a terminal"

	# shellcheck disable=SC2016  # expanded by zsh, not here
	read -r autosuggest highlight prompt <<<"$(tty_zsh \
		'print ${+functions[_zsh_autosuggest_start]} ${+functions[_zsh_highlight]} ${+functions[p10k]}')"
	[ "$autosuggest" = 1 ] || fail "zsh-autosuggestions did not load"
	[ "$highlight" = 1 ]   || fail "zsh-syntax-highlighting did not load"
	[ "$prompt" = 1 ]      || fail "powerlevel10k did not load"
	ok "plugins and powerlevel10k load"

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
if [ ! -f "$DOTFILES_ROOT/zsh/p10k.zsh" ]; then
	info "powerlevel10k isn't configured yet: its wizard starts by itself in that new tab (or run: p10k configure)"
fi
