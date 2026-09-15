# Installing the zsh setup

How to set up what [readme.md](readme.md) describes on a Mac. The installer
is safe to run again at any time: it never deletes anything, and whatever it
replaces goes to `~/.dotfiles-backup/<timestamp>/`.

## 1. Requirements

- **macOS with zsh as your login shell** — the default since macOS Catalina.
  `echo $SHELL` should print `/bin/zsh`; if it doesn't, run
  `chsh -s /bin/zsh` and log out and back in.
- **git and a network connection.** The installer downloads powerlevel10k and
  the plugins from GitHub.
- **iTerm2** — the colors are tuned for it. The terminals in VS Code and
  Cursor work too.
- **Homebrew** is optional. When it's installed, new shells use its tools
  (git, node, …) ahead of the ones Apple ships.

## 2. Get the repo

```bash
git clone git@github.com:avmax/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

The repo can live in any folder; the installer works out its paths from where
it is.

## 3. Run the installer

See what it would do, without changing anything:

```bash
DRY_RUN=1 ./index.sh zsh
```

Then install:

```bash
./index.sh zsh
```

It:

1. **Retires earlier setups** by moving them to the backup folder:
   `~/.oh-my-zsh`, old `~/.zcompdump*` files, and a Starship prompt an
   earlier version of this repo installed. `~/.zhistory`, where the 2019
   config kept history, is added to `~/.zsh_history` first.
2. **Links** `~/.zprofile` and `~/.zshrc` to the files in `zsh/`, backing up
   any existing ones.
3. **Makes `~/.zshrc.local` private** (mode 600), if you have one.
4. **Downloads or updates four plugins** in `~/.local/share/zsh/plugins`:
   powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting and
   zsh-completions.
5. **Downloads gitstatusd** into `~/.cache/gitstatus` — the small program
   powerlevel10k uses to read git status quickly.
6. **Checks the result:** every file parses, a new shell starts without
   printing anything (both in a terminal and without one), the plugins and
   the prompt load, and git and npm have Tab completion.

If anything goes wrong it stops with a `fail` line that says what; see
[Troubleshooting](#troubleshooting).

## 4. Set up the terminal

### iTerm2

1. Settings → Profiles → Colors → Color Presets → **Solarized Light**.
2. The prompt's icons need the **MesloLGS NF** font. Either:
   - download the four files from the powerlevel10k project —
     [Regular](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf),
     [Bold](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf),
     [Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf),
     [Bold Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
     — double-click each one to install it, then choose **MesloLGS NF** in
     Settings → Profiles → Text → Font; or
   - run `p10k configure` in iTerm2. Its first question offers to install the
     font and switch iTerm2 to it, then it asks you to restart iTerm2. If you
     carry on through the wizard it replaces `zsh/p10k.zsh` with your answers:
     press `q` at any question to stop without changing anything, or run
     `git checkout zsh/p10k.zsh` afterwards to get the repo's prompt back.
3. Optional: Settings → Profiles → Text → Cursor → **Vertical Bar**.

### VS Code and Cursor

With MesloLGS NF installed, add this to your settings (⌘, then the `{}` icon
in the top right):

```json
"terminal.integrated.fontFamily": "MesloLGS NF"
```

Their terminals take colors from the editor's theme, not from iTerm2. The
command-line colors are picked for a light background, so they read best with
a light theme.

## 5. Open a new tab

Open a new terminal tab, or run `exec zsh` in one that's already open — tabs
from before the install keep the old config until you do.

You should see the prompt with your folder in blue. As you type, a command
turns green if it exists or faded green if it doesn't, and a suggestion from
your history appears after the cursor.

## Updating

Run the installer again:

```bash
cd ~/.dotfiles && ./index.sh zsh
```

It updates the plugins, leaves everything that's already in place alone, and
runs the checks again.

## Troubleshooting

| you see | what to do |
| --- | --- |
| `fail a new zsh … printed … on startup` | the lines after it are what zsh printed. Usually a mistake in `~/.zshrc.local` or in a file in `zsh/` |
| `fail could not update …/plugins/<name>` | that plugin's folder has local changes. Move the folder away and run the installer again |
| `fail could not download gitstatusd` | GitHub couldn't be reached. Run the installer again when you're online |
| `warn your login shell is …` | run `chsh -s /bin/zsh`, then log out and back in |
| boxes or question marks instead of icons | the terminal isn't using MesloLGS NF — see [step 4](#4-set-up-the-terminal) |
| `zsh: skipped insecure completion directories` | a completion folder can be written by another user. `compaudit` lists which |
| a tab still shows the old prompt or colors | it was opened before the change. Run `exec zsh` |

### Homebrew owned by another account

If `/opt/homebrew` belongs to a different macOS user, `brew install` fails for
you, and zsh would normally warn that Homebrew's completion folder is
insecure. This config uses those completions anyway, but the real fix is to
take ownership of Homebrew — only if nobody uses it from the other account:

```bash
sudo chown -R "$(whoami)" /opt/homebrew
```

## Rolling back

Remove the two links, then move back what the installer set aside:

```bash
rm ~/.zprofile ~/.zshrc
ls -A ~/.dotfiles-backup/<timestamp>/        # what was replaced at that install
mv ~/.dotfiles-backup/<timestamp>/.zshrc ~/  # for example
```

Once you don't need them, you can delete the plugins in
`~/.local/share/zsh/plugins` and the caches in `~/.cache/zsh`,
`~/.cache/gitstatus` and `~/.cache/p10k-*`.
