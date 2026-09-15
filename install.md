# Setting up a new Mac

The short version, in the order to do it. Every step has more detail in
[README.md](README.md).

## 1. Get git

A fresh Mac has no git until the Command Line Tools are installed. Run:

```bash
git --version
```

If git is missing, macOS offers to install the tools — accept, and run the
command again. Apple's git is recent enough for this repo (it needs ≥ 2.38).

## 2. Clone the repo

```bash
git clone https://github.com/avmax/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

HTTPS, because a new Mac has no SSH key on GitHub yet. Once a key is in place,
switch the remote over:

```bash
git remote set-url origin git@github.com:avmax/.dotfiles.git
```

## 3. See what can be installed

```bash
./install.sh
```

Each topic is installed on its own, in any order. The ones that are ready:
`git`, `zsh`, `apps-and-tools`, `iTerm`.

## 4. Preview anything before you run it

```bash
DRY_RUN=1 ./install.sh git
```

This prints every `mv` and `ln` it would do and changes nothing. Worth doing
the first time on a new machine.

## 5. Install

```bash
./install.sh git
./install.sh apps-and-tools
./install.sh zsh
./install.sh iTerm
```

In that order: `apps-and-tools` installs Homebrew and iTerm2, `zsh` sets up the
prompt you'll use in them, and `iTerm` gives iTerm2 the profile and key
bindings that prompt is tuned for. Some steps ask for your password (the
Homebrew and AmneziaVPN installers, and the App Store helper). Installing a
topic again is safe: anything already in place is left alone, and anything
replaced is moved to `~/.dotfiles-backup/<timestamp>/` rather than deleted.

Run `./install.sh iTerm` **from Terminal.app, with iTerm2 quit** — iTerm2
writes its own settings back out when it quits, which would undo the import.
The installer stops rather than let that happen.

## 6. Open a new terminal tab

The zsh config only applies to shells started after the install. The `iTerm`
topic already set the **Solarized Light** colors the prompt is tuned for; the
**MesloLGS NF** font its icons need is four files to install by hand — see
[zsh/install.md](zsh/install.md#4-set-up-the-terminal). If the powerlevel10k
wizard opens by itself, that's expected on the first tab.

## 7. The rest, by hand

- Machine-specific git settings (work email, signing key) go in
  `~/.gitconfig.local` — README, *Identity vs. local overrides*.
- macOS tweaks: screenshots folder, Finder, window management — README,
  *Manual setup*.
- Apps outside the installer's list — README, *Apps and tools*.
- tmux and vim have config in the repo but no installer yet.

## Keep the repo where it is

`~/.gitconfig`, `~/.zshrc` and `~/.zprofile` become symlinks into this folder.
It doesn't have to be `~/.dotfiles`, but once installed, moving or deleting the
folder breaks them.
