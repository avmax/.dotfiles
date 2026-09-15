# .dotfiles

Personal macOS development setup. Config lives in this repo; short installers
symlink it into `$HOME`.

Every installer is **idempotent** (run it as often as you like) and
**non-destructive** (anything it would overwrite is moved to
`~/.dotfiles-backup/<timestamp>/` first, never deleted).

## Status

| topic  | config in repo | installer | notes |
| ------ | -------------- | --------- | ----- |
| git    | ✅ `git/`      | ✅ `install/git.sh` | modernized, requires git ≥ 2.38 |
| zsh    | ✅ `zsh/`      | ✅ `install/zsh.sh` | modernized: no oh-my-zsh, powerlevel10k prompt |
| tmux   | ✅ `tmux/`     | ❌ | still in legacy `install/setup.sh` |
| vim    | ✅ `vim/`      | ❌ | still in legacy `install/setup.sh` |
| sublime | ✅ `sublime/` | ❌ | unmaintained — kept for archaeology |
| spectacle | ✅ `spectacle/` | ❌ | Spectacle is discontinued; see [Window management](#window-management) |

Topics are migrated to the new installer contract one at a time. Until a topic
has an `install/<topic>.sh`, its setup steps live in `install/setup.sh`, which
is **legacy and destructive** — read it before running any of it by hand.

## Install

```bash
git clone git@github.com:avmax/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./index.sh            # list topics
./index.sh git        # install one
```

The repo does not have to live in `~/.dotfiles` — every installer resolves
paths from its own location.

### Preview before changing anything

```bash
DRY_RUN=1 ./index.sh git
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
./index.sh git
```

Creates:

| path | kind | source |
| ---- | ---- | ------ |
| `~/.gitconfig` | symlink | `git/gitconfig` |
| `~/.gitignore_global` | symlink | `git/gitignore_global` |
| `~/.gitconfig.local` | copy, once | `git/gitconfig.local.example` |

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
`include`d last so it wins:

```ini
# ~/.gitconfig.local
[user]
	email = me@work.example
```

See `git/gitconfig.local.example` for per-directory identities
(`includeIf "gitdir:"`) and ssh commit signing.

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
./index.sh zsh
```

Creates:

| path | kind | source |
| ---- | ---- | ------ |
| `~/.zprofile` | symlink | `zsh/zprofile` — login shells: `PATH`, Homebrew first |
| `~/.zshrc` | symlink | `zsh/zshrc` — interactive shells |
| `~/.zshrc.local` | copy, once, mode 600 | `zsh/zshrc.local.example` |
| `~/.local/share/zsh/plugins/` | git clones | powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions |
| `~/.cache/gitstatus/` | download | gitstatusd, which powerlevel10k uses for git status |

Re-running it updates the plugins. It then starts fresh login shells, with
and without a terminal, and fails if either prints anything on startup, if a
plugin or the prompt didn't load, or if git / npm have no completion.

No framework: oh-my-zsh is gone. The installer retires it without deleting
anything —
`~/.oh-my-zsh`, an earlier Starship setup and old `~/.zcompdump*` files move
to the backup dir, and
`~/.zhistory`, where the old config wrote history, is appended to
`~/.zsh_history` first.

### What's in `zsh/`

| file | contents |
| ---- | -------- |
| `zshrc` | loads the modules below, powerlevel10k with its instant prompt, then `~/.zshrc.local` |
| `options.zsh` | `EDITOR`, `LESS`, history, directory options |
| `colors.zsh` | every color except the prompt's: ls, completion lists, and the command line as you type — a Solarized Light scheme, with dangerous commands in red |
| `completion.zsh` | `compinit` with a cache in `~/.cache/zsh`, menu |
| `aliases.zsh` | `ll`/`la`, safe `rm`; `chrome`/`firefox`/`safari` (take a URL, bare domain or file), `telegram` |
| `functions.zsh` | `up`, `mkcddir`, `gitroot`, `f`, `replace`, `extract`, `port`/`killport`, `nr` (Tab completes script names), `myip`, `cls` |
| `keybindings.zsh` | every binding commented with its key and action; ↑/↓ search history by what's typed |
| `plugins.zsh` | autosuggestions, then syntax highlighting — which must load last — plus two small highlighters: fade a mistyped command, darken quote marks |
| `p10k.zsh` | powerlevel10k settings, written by `p10k configure` |

Secrets and per-machine settings go in `~/.zshrc.local`, never in the repo.
Start a command with a space to keep it out of history.

### Prompt

[Powerlevel10k](https://github.com/romkatv/powerlevel10k), set up through
its configuration wizard. While `zsh/p10k.zsh` doesn't exist, the wizard
starts by itself in every new terminal tab; `p10k configure` runs it again
later. It writes its answers straight into `zsh/p10k.zsh` in this repo —
commit that file. It won't offer to edit `~/.zshrc`: `zsh/zshrc` already has
the instant-prompt block and the `source` line it looks for.

- **Font.** The icons need a Nerd Font. Run the wizard in iTerm2 and it
  offers to download *MesloLGS NF* and switch the iTerm2 profile to it.
  Other terminals then only need the font selected — for VS Code and
  Cursor: `"terminal.integrated.fontFamily": "MesloLGS NF"`.
- **Instant prompt.** The prompt appears before the rest of the config has
  loaded, so nothing in the config may print during startup. The wizard's
  *verbose* mode warns if something does.
- **Real terminals only.** It's skipped in dumb terminals and in shells with
  no terminal at all, like the `zsh -lic` IDEs run to read your environment:
  its git helper can't start there and would print errors.
- **Support.** Upstream says the project has very limited support: no new
  features, and most bugs will go unfixed.

### Homebrew owned by another account

If `/opt/homebrew` belongs to a different macOS user, `brew install` fails
for you and zsh reports Homebrew's completion directory as insecure. The
config copes by using those completions anyway, but the real fix is
ownership:

```bash
sudo chown -R "$(whoami)" /opt/homebrew
```

That takes Homebrew away from the other account, so only do it if nobody
uses brew there.

### Rolling it back

```bash
ls ~/.dotfiles-backup/                       # pick a timestamp
rm ~/.zprofile ~/.zshrc                      # remove the symlinks
mv ~/.dotfiles-backup/<timestamp>/.oh-my-zsh ~/.oh-my-zsh
git checkout master -- zsh/                  # the 2019 config, then relink:
ln -s ~/.dotfiles/zsh/index.zsh ~/.zshrc
```

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

### iTerm2

1. Settings → Profiles → Colors → *Color Presets* → **Solarized Light**
2. Font: run `p10k configure` in iTerm2 — it installs **MesloLGS NF** and
   switches the profile to it (see [Prompt](#prompt))
3. Settings → Profiles → Text → Cursor: **Vertical Bar**

### VS Code

VS Code has built-in Settings Sync now — the third-party *Settings Sync*
extension the old README pointed at is no longer needed. Turn it on from the
account menu in the bottom-left. The old
[settings gist](https://gist.github.com/avmax/4296510c21aeee0ab94684d3d3bc61c2)
is kept only as a reference.

## Applications

Most of these are installable with Homebrew Cask, which is easier to keep
current than downloading disk images by hand:

| app | download |
| --- | -------- |
| Bitwarden | <https://bitwarden.com/> |
| Telegram | <https://desktop.telegram.org/> |
| Chrome / Chrome Canary | <https://www.google.com/chrome> |
| Firefox | <https://www.mozilla.org/firefox/new/> |
| Tor Browser | <https://www.torproject.org/download/> |
| Miro | <https://miro.com/apps/> |
| Figma | <https://www.figma.com/downloads/> |
| VS Code | <https://code.visualstudio.com/download> |
| iTerm2 | <https://iterm2.com/downloads.html> |
| Slack | <https://slack.com/downloads/mac> |
| Notion | <https://www.notion.so/desktop> |
| Docker Desktop | <https://www.docker.com/products/docker-desktop> |
| Postman | <https://www.postman.com/downloads/> |
| Rectangle | <https://rectangleapp.com/> |

Cask names drift between releases, so look the current one up rather than
trusting a hardcoded list:

```bash
brew search <app>
brew install --cask <exact-cask-name>
```

A `Brewfile` would be the right way to pin all of this — see *Recommendations*
in the branch discussion; it is not set up yet.

`install/apps.sh` is an older, entirely commented-out attempt at scripting
`.dmg`/`.zip` downloads. Homebrew Cask replaces it; the file is kept for
reference.

## Repository layout

```
.
├── index.sh                  entry point — ./index.sh <topic>
├── install/
│   ├── lib.sh                shared helpers (link_file, backups, DRY_RUN)
│   ├── git.sh                git topic installer
│   ├── zsh.sh                zsh topic installer
│   ├── setup.sh              LEGACY — tmux/vim, destructive
│   ├── download.sh           LEGACY — brew installs
│   └── apps.sh               LEGACY — commented-out .dmg downloads
├── git/
│   ├── gitconfig             -> ~/.gitconfig
│   ├── gitignore_global      -> ~/.gitignore_global
│   └── gitconfig.local.example
├── zsh/
│   ├── zprofile              -> ~/.zprofile
│   ├── zshrc                 -> ~/.zshrc (loads the *.zsh modules)
│   ├── *.zsh                 modules loaded by zshrc
│   ├── p10k.zsh              powerlevel10k settings, written by p10k configure
│   └── zshrc.local.example
├── tmux/ vim/                config, not yet migrated
├── spectacle/                legacy window-manager shortcuts
└── sublime/                  unmaintained
```

## Adding a topic

1. Put the config in `<topic>/`.
2. Write `install/<topic>.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

link_file "$DOTFILES_ROOT/<topic>/rc" "$HOME/.<topic>rc"

summary
ok "<topic> dotfiles installed"
```

3. Add the topic to `READY` in `index.sh` and to the status table above.
4. Verify with `DRY_RUN=1 ./index.sh <topic>`, then run it twice — the second
   run must report `already linked` and change nothing.
