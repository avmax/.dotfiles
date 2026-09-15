# .dotfiles

Personal macOS development setup. Config lives in this repo; short installers
symlink it into `$HOME`.

Every installer is **idempotent** (run it as often as you like) and
**non-destructive** (anything it would overwrite is moved to
`~/.dotfiles-backup/<timestamp>/` first, never deleted).

## Status

| topic  | config in repo | installer | notes |
| ------ | -------------- | --------- | ----- |
| git    | ✅ `git/`      | ✅ `_install-scripts/git.sh` | modernized, requires git ≥ 2.38 |
| zsh    | ✅ `zsh/`      | ✅ `_install-scripts/zsh.sh` | modernized: no oh-my-zsh, powerlevel10k prompt |
| apps-and-tools | — | ✅ `_install-scripts/apps-and-tools.sh` | developer tools and desktop apps — see [Apps and tools](#apps-and-tools) |
| iTerm  | ✅ `iTerm/`    | ✅ `_install-scripts/iTerm.sh` | iTerm2's profiles, key bindings and app settings — see [iTerm2](#iterm2) |
| tmux   | ✅ `tmux/`     | ❌ | no installer yet |
| vim    | ✅ `vim/`      | ❌ | no installer yet |
| spectacle | ✅ `spectacle/` | ❌ | Spectacle is discontinued; see [Window management](#window-management) |

Topics are migrated to the new installer contract one at a time. Until a topic
has an `_install-scripts/<topic>.sh`, set it up by hand. The old all-in-one
setup script has been removed; its tmux and vim steps are still in git history
(`git log -- install/setup.sh`, the path it had back then).

## Install

Setting up a new Mac? Follow [install.md](install.md) — it's the short version
of this file, in order.

```bash
git clone git@github.com:avmax/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh            # install every ready topic, in order
./install.sh git        # install just one
./install.sh -h         # list the topics
```

The repo does not have to live in `~/.dotfiles` — every installer resolves
paths from its own location.

### Preview before changing anything

```bash
DRY_RUN=1 ./install.sh git
```

Prints every `mv` / `ln` it would run and touches nothing.

### Environment variables

| variable | default | purpose |
| -------- | ------- | ------- |
| `DRY_RUN` | `0` | `1` prints actions instead of performing them |
| `DOTFILES_BACKUP_DIR` | `~/.dotfiles-backup/<timestamp>` | where replaced files go |
| `DOTFILES_ROOT` | resolved from the script path | override the repo root |

## git

```bash
./install.sh git
```

Creates:

| path | kind | source |
| ---- | ---- | ------ |
| `~/.gitconfig` | symlink | `git/gitconfig` |
| `~/.gitignore_global` | symlink | `git/gitignore_global` |

**Requires git ≥ 2.38.** The config uses `merge.conflictstyle=zdiff3`,
`push.autoSetupRemote`, `rebase.updateRefs` and `help.autocorrect=prompt`;
older git *errors out* on these rather than ignoring them, so the installer
refuses to run and tells you to `brew install git`. Check with:

```bash
git --version
```

Note that macOS ships its own git at `/usr/bin/git`. If Homebrew's git is
installed but `git --version` still shows an Apple build, your `PATH` has
`/usr/bin` before `/opt/homebrew/bin` (Apple Silicon) or `/usr/local/bin`
(Intel).

### Identity vs. local overrides

`git/gitconfig` is tracked and this repo is public, so it holds only the
personal identity that is already public on GitHub. Everything
machine-specific goes in `~/.gitconfig.local`, which is never tracked and is
`include`d last so it wins. The installer does not create it; make it by hand
when a machine needs one (git skips the include if it is missing):

```ini
# ~/.gitconfig.local
[user]
	email = me@work.example
```

### What the config sets

Beyond the identity and the aliases:

- **safer defaults** — `pull.rebase`, `fetch.prune`, `fetch.pruneTags`,
  `rebase.autoStash`, `rebase.autoSquash`, `rebase.updateRefs`,
  `push.autoSetupRemote`, `push.followTags`
- **readable diffs** — `diff.algorithm=histogram`, `diff.colorMoved`,
  `diff.mnemonicPrefix`, `diff.renames=copies`
- **easier conflicts** — `merge.conflictstyle=zdiff3` (shows the common
  ancestor), `rerere.enabled` (replays a resolution you have done before)
- **sane listings** — `init.defaultBranch=main`, `branch.sort=-committerdate`,
  `tag.sort=version:refname`, `column.ui=auto`
- **macOS credentials** — `credential.helper=osxkeychain`

`git aliases` lists every alias; `git whoami` prints the active identity.

### Rolling it back

```bash
ls ~/.dotfiles-backup/                       # pick a timestamp
rm ~/.gitconfig ~/.gitignore_global          # remove the symlinks
cp ~/.dotfiles-backup/<timestamp>/.gitconfig ~/.gitconfig
```

## zsh

```bash
./install.sh zsh
```

A plain zsh setup with no framework: a powerlevel10k prompt, fish-style
suggestions, syntax highlighting, and one color scheme tuned for iTerm2's
Solarized Light preset.

- [zsh/install.md](zsh/install.md) — requirements, what the installer does,
  terminal and font setup, updating, troubleshooting, rolling back
- [zsh/readme.md](zsh/readme.md) — how the config is organized, aliases,
  functions, keys, colors, the prompt, and local settings

## iTerm2

```bash
./install.sh iTerm
```

Imports `iTerm/com.googlecode.iterm2.plist` into the `com.googlecode.iterm2`
defaults domain: the profile with its Solarized Light colors and MesloLGS NF
font, the key and mouse bindings, and the app-wide settings. They apply the
next time iTerm2 starts.

**Quit iTerm2 first** (⌘Q) and run it from Terminal.app — iTerm2 writes its
profiles back out when it quits, which would undo the import. The installer
refuses to run rather than let that happen; `DRY_RUN=1` works either way.

The font itself is not installed by this (see
[zsh/install.md](zsh/install.md#4-set-up-the-terminal)); the installer warns if
it is missing.

Changed something in iTerm2's settings? Put it in the repo with:

```bash
./iTerm/export.sh
git diff -- iTerm/
```

[iTerm/readme.md](iTerm/readme.md) — exactly what is captured, what is left out
as machine-local, and how to roll back.

## Manual setup

Things macOS does not let a script do reliably, or that are one-off.

### Screenshots

```bash
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
killall SystemUIServer
```

### Finder

```bash
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder
```

Then, in Finder settings: show Home in the sidebar, and set search scope to
the current folder.

### Window management

`spectacle/Shortcuts.json` targets [Spectacle](https://www.spectacleapp.com/),
which was **discontinued in 2020**. Its maintained successor is
[Rectangle](https://rectangleapp.com/), which can import Spectacle shortcuts:

```bash
brew install --cask rectangle
```

Then Rectangle → Settings → *Import* → point it at
`~/.dotfiles/spectacle/Shortcuts.json`.

### VS Code

VS Code has built-in Settings Sync now — the third-party *Settings Sync*
extension the old README pointed at is no longer needed. Turn it on from the
account menu in the bottom-left. The old
[settings gist](https://gist.github.com/avmax/4296510c21aeee0ab94684d3d3bc61c2)
is kept only as a reference.

## Apps and tools

```bash
./install.sh apps-and-tools
```

Installs whatever is missing from two lists, and skips anything that's already
installed — however it got there.

**Developer tools**

| tool | from |
| ---- | ---- |
| Homebrew | the installer from [brew.sh](https://brew.sh) |
| node, npm, npx | Homebrew `node` |
| python3, pip3 | Homebrew `python` |
| PostgreSQL 18 | Homebrew `postgresql@18`, with `psql` and the rest linked onto `PATH` |

**Desktop apps**

| app | from |
| --- | ---- |
| iTerm2 | Homebrew Cask `iterm2` |
| Google Chrome | Homebrew Cask `google-chrome` |
| Visual Studio Code | Homebrew Cask `visual-studio-code` |
| Firefox | Homebrew Cask `firefox` |
| Telegram | Homebrew Cask `telegram` |
| AmneziaVPN | Homebrew Cask `amneziavpn` |
| WireGuard | Mac App Store, with [mas](https://github.com/mas-cli/mas) — the only place WireGuard for macOS is released |

A tool counts as installed when its commands are on `PATH` (macOS's own
`/usr/bin/python3` and `pip3` don't count), and PostgreSQL also when Homebrew
already has some `postgresql@N` or Postgres.app is there. An app counts when
it's in `/Applications` or `~/Applications`.

Good to know:

- **PostgreSQL isn't started.** `brew services start postgresql@18` runs it now
  and at every login.
- **Python is `python3` and `pip3`.** Homebrew keeps the unversioned `python`
  and `pip` in `$(brew --prefix python)/libexec/bin`, which isn't on `PATH`.
- **Homebrew owned by another macOS user** makes `brew install` fail. The
  script warns about it up front; the fix is in
  [zsh/install.md](zsh/install.md#homebrew-owned-by-another-account).
- **Right after installing Homebrew**, skip its "Next steps": `zsh/zprofile`
  already puts `brew` on `PATH` (`./install.sh zsh`).
- **WireGuard** needs an Apple Account signed in to the App Store. mas is
  installed with Homebrew the first time WireGuard is missing; if mas can't
  install it, the script opens WireGuard's App Store page instead.
- The Homebrew installer, the AmneziaVPN installer and mas ask for your
  password.

Each install is checked: if something didn't land, the run ends with an error
naming it. When a formula or cask has been renamed, `brew search <name>` finds
the new name.

Everything else is installed by hand — most have a cask too
(`brew search <app>`):

| app | download |
| --- | -------- |
| Bitwarden | <https://bitwarden.com/> |
| Chrome Canary | <https://www.google.com/chrome/canary/> |
| Tor Browser | <https://www.torproject.org/download/> |
| Miro | <https://miro.com/apps/> |
| Figma | <https://www.figma.com/downloads/> |
| Slack | <https://slack.com/downloads/mac> |
| Notion | <https://www.notion.so/desktop> |
| Docker Desktop | <https://www.docker.com/products/docker-desktop> |
| Postman | <https://www.postman.com/downloads/> |
| Rectangle | <https://rectangleapp.com/> |

A `Brewfile` would be the right way to pin all of this — see *Recommendations*
in the branch discussion; it is not set up yet.

## Repository layout

```
.
├── install.sh                entry point — ./install.sh <topic>
├── install.md                setting up a new Mac, step by step
├── _install-scripts/
│   ├── git.sh                git topic installer
│   ├── zsh.sh                zsh topic installer
│   ├── apps-and-tools.sh     developer tools and desktop apps
│   └── iTerm.sh              iTerm2 topic installer
├── git/
│   ├── gitconfig             -> ~/.gitconfig
│   └── gitignore_global      -> ~/.gitignore_global
├── zsh/
│   ├── readme.md             how the zsh setup works
│   ├── install.md            how to install it
│   ├── zprofile              -> ~/.zprofile
│   ├── zshrc                 -> ~/.zshrc (loads the *.zsh modules)
│   ├── custom-functions.zsh  every function, shell and installer alike
│   ├── *.zsh                 modules loaded by zshrc
│   └── p10k.zsh              powerlevel10k settings, written by p10k configure
├── iTerm/
│   ├── readme.md             what is captured and how
│   ├── com.googlecode.iterm2.plist   -> the com.googlecode.iterm2 defaults domain
│   └── export.sh             update that file from this Mac's settings
├── tmux/ vim/                config, not yet migrated
└── spectacle/                legacy window-manager shortcuts
```

## Adding a topic

1. Put the config in `<topic>/`.
2. Write `_install-scripts/<topic>.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/zsh/custom-functions.zsh"

link_file "$DOTFILES_ROOT/<topic>/rc" "$HOME/.<topic>rc"

summary
ok "<topic> dotfiles installed"
```

3. Add the topic to `READY` in `install.sh` and to the status table above.
4. Verify with `DRY_RUN=1 ./install.sh <topic>`, then run it twice — the second
   run must report `already linked` and change nothing.
