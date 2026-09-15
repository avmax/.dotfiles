Setting up a new Mac. More on any of this in [README.md](README.md).

1. Check git with `git --version`. If it's missing, macOS offers the Command
   Line Tools — accept, then run it again.

2. Clone the repo. HTTPS, because a new Mac has no SSH key on GitHub yet:

   ```bash
   git clone https://github.com/avmax/.dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. Quit iTerm2 (⌘Q) and run this from **Terminal.app**:

   ```bash
   ./install.sh
   ```

   It installs everything — git, apps and tools, zsh, iTerm2's settings — and
   asks for your password a few times (the Homebrew and AmneziaVPN installers,
   the App Store helper). `DRY_RUN=1 ./install.sh` shows what it would do
   without doing it. Running it again is safe: anything replaced is kept in
   `~/.dotfiles-backup/<timestamp>/`.

4. Install the **MesloLGS NF** font by hand, for the prompt's icons — four
   files, see [zsh/install.md](zsh/install.md#4-set-up-the-terminal).

5. Open a new iTerm2 tab. Prompt, colors and key bindings are in place; the
   powerlevel10k wizard opening on the first tab is expected.

6. Left by hand: `~/.gitconfig.local` for a work email or signing key, the
   macOS tweaks under *Manual setup* in README, and tmux and vim, which have no
   installer yet.

Keep the repo where it is — `~/.gitconfig`, `~/.zshrc` and `~/.zprofile` become
symlinks into it, and moving the folder breaks them.
