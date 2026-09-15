#!/usr/bin/env bash
#
# Entry point for the dotfiles. Installs one or more topics.
#
#   ./install.sh                # show what's available
#   ./install.sh git            # install just the git dotfiles
#   ./install.sh git vim        # install several
#   DRY_RUN=1 ./install.sh git  # preview, change nothing
#
# Each topic is a script at _install-scripts/<topic>.sh. Topics are
# independent and idempotent — run one, run it again, run another, in any
# order.

set -euo pipefail
cd "$(dirname "$0")"

ROOT="$(pwd -P)"

# Topics that have been migrated to the new installer contract.
READY=(git zsh apps-and-tools)

# Config lives in the repo but has no installer yet — see README.
PENDING=(tmux vim)

usage() {
	cat <<EOF
usage: ./install.sh <topic> [<topic>...]

ready:
$(printf '  %s\n' "${READY[@]}")

not migrated yet (config is in the repo, but no installer):
$(printf '  %s\n' "${PENDING[@]}")

env:
  DRY_RUN=1            print what would happen, change nothing
  DOTFILES_BACKUP_DIR  where replaced files go (default ~/.dotfiles-backup/<ts>)
EOF
}

if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	usage
	exit 0
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
