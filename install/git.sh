#!/usr/bin/env bash
#
# Install the git dotfiles.
#
#   ~/.gitconfig         -> symlink to <repo>/git/gitconfig
#   ~/.gitignore_global  -> symlink to <repo>/git/gitignore_global
#
# Safe to run repeatedly. Anything it would overwrite is backed up first.
# Preview without touching anything:  DRY_RUN=1 ./install/git.sh

set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"

# git/gitconfig uses zdiff3, push.autoSetupRemote, rebase.updateRefs and
# help.autocorrect=prompt. All of those land in 2.35–2.38; an older git
# errors out on them rather than ignoring them, so gate up front.
MIN_GIT_VERSION=2.38.0

require_cmd git "Install it with: brew install git"

GIT_VERSION="$(git --version | awk '{print $3}')"
if ! version_ge "$GIT_VERSION" "$MIN_GIT_VERSION"; then
	fail "git $GIT_VERSION is too old — git/gitconfig needs >= $MIN_GIT_VERSION.
     Fix: brew install git, then open a new shell so /opt/homebrew/bin
     (or /usr/local/bin) comes before /usr/bin in \$PATH."
fi
ok "git $GIT_VERSION"

info "linking git config"
link_file "$DOTFILES_ROOT/git/gitconfig"        "$HOME/.gitconfig"
link_file "$DOTFILES_ROOT/git/gitignore_global" "$HOME/.gitignore_global"

if [ "$DRY_RUN" != "1" ]; then
	info "verifying git accepts the config"

	# Reading config back exercises the parser and catches typos / bad sections.
	git config --global --list >/dev/null \
		|| fail "git could not parse ~/.gitconfig — see the error above"

	# Exercise the version-sensitive keys for real, in a throwaway repo, so a
	# bad value fails here instead of mid-merge six weeks from now.
	probe="$(mktemp -d)"
	trap 'rm -rf "$probe"' EXIT
	(
		cd "$probe"
		git init --quiet .
		git -c user.name=probe -c user.email=probe@local commit \
			--quiet --allow-empty -m probe
		git status --short >/dev/null
		git log -1 --pretty=%h >/dev/null
		git diff HEAD >/dev/null
	) || fail "git failed while exercising the new config in a scratch repo"

	ok "config parses and runs clean"
	ok "identity: $(git config --global user.name) <$(git config --global user.email)>"
	ok "excludesfile: $(git config --global core.excludesfile)"
fi

summary
ok "git dotfiles installed"
