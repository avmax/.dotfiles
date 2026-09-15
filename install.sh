#!/usr/bin/env bash
#
# Entry point for the dotfiles. Installs one or more topics.
#
#   ./install.sh                # install every ready topic, in order
#   ./install.sh git            # install just the git dotfiles
#   ./install.sh git vim        # install several
#   ./install.sh -h             # list the topics
#   DRY_RUN=1 ./install.sh      # preview, change nothing
#
# Each topic is a script at _install-scripts/<topic>.sh. Topics are
# independent and idempotent — run one, run it again, run another, in any
# order.

set -euo pipefail
cd "$(dirname "$0")"

ROOT="$(pwd -P)"

# Topics that have been migrated to the new installer contract. A run with no
# arguments installs them in this order: Homebrew and iTerm2 arrive before the
# zsh prompt that runs in them, and iTerm2's own settings go last.
READY=(git apps-and-tools zsh iTerm)

# Config lives in the repo but has no installer yet — see README.
PENDING=(tmux vim)

usage() {
	cat <<EOF
usage: ./install.sh [<topic>...]

with no topic, installs every ready one, in this order:
$(printf '  %s\n' "${READY[@]}")

not migrated yet (config is in the repo, but no installer):
$(printf '  %s\n' "${PENDING[@]}")

env:
  DRY_RUN=1            print what would happen, change nothing
  DOTFILES_BACKUP_DIR  where replaced files go (default ~/.dotfiles-backup/<ts>)
EOF
}

if [ "$#" -gt 0 ] && { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
	usage
	exit 0
fi

# No topic named: install all of them.
if [ "$#" -eq 0 ]; then
	set -- "${READY[@]}"
fi

for script in "$@"; do
	script_path="$ROOT/_install-scripts/$script.sh"

	if [ ! -f "$script_path" ]; then
		echo "no installer for '$script'" >&2
		echo >&2
		usage >&2
		exit 1
	fi

	echo "==> $script"
	bash "$script_path"
	echo
done
