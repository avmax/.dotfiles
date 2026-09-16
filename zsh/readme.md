# zsh

A plain zsh setup with no framework: a
[powerlevel10k](https://github.com/romkatv/powerlevel10k) prompt, suggestions
as you type, syntax highlighting, and one color scheme tuned for iTerm2's
Solarized Light preset. To set it up on a Mac, see [install.md](install.md).

## Files

The installer links two files into your home folder; `zshrc` loads the rest
from this folder, in the order below.

| file | linked as | what it does |
| --- | --- | --- |
| `zprofile` | `~/.zprofile` | login shells: `PATH` with Homebrew first, `~/.local/bin`, VS Code's `code` |
| `zshrc` | `~/.zshrc` | interactive shells: loads everything below |
| `options.zsh` | | editor, pager, history, directory and correction options |
| `colors.zsh` | | every color: ls, completion lists, the command line, the prompt |
| `completion.zsh` | | Tab completion |
| `aliases.zsh` | | aliases and the browser launchers |
| `custom-functions.zsh` | | every function: the shell functions below, plus the installers' helpers, which only bash loads |
| `keybindings.zsh` | | keys for editing the command line |
| `p10k.zsh` | | the prompt's layout, written by `p10k configure` |
| `plugins.zsh` | | suggestions and syntax highlighting, loaded last |

Finally `zshrc` loads `~/.zshrc.local`, if you have one — see
[Local settings](#local-settings).

After changing any of these files, open a new tab or run `exec zsh` (the
`szrc` alias does that).

## History and directories

- History is kept in `~/.zsh_history`: 50,000 commands with timestamps,
  shared between open tabs as you go, without duplicates.
- **Start a command with a space** to keep it out of history — useful for
  anything containing a secret.
- `!!` and other history shortcuts expand onto the line first, so you see
  the command before it runs.
- Type a folder's name on its own to `cd` into it. `cd -<Tab>` lists the
  folders you were in recently.
- When you mistype a command's name, zsh offers to correct it.

## Completion

- Press Tab: with two or more matches a menu opens. Arrow keys move through
  it, ⇧-Tab goes back.
- Matching ignores case — `cd doc<Tab>` finds `Documents`.
- git, npm, brew and hundreds of other commands complete their subcommands
  and options. `nr <Tab>` completes the scripts in your package.json;
  `kill <Tab>` lists your processes.

## Aliases

| alias | runs |
| --- | --- |
| `..` / `...` | `cd ..` / `cd ../..` |
| `projects` | `cd ~/Code` |
| `ll` / `la` | `ls -lh` / `ls -lah` |
| `lr` / `ld` / `lh` / `lf` | long listing / folders only / hidden entries only / files only |
| `rm` | `rm -i`, which asks before each delete |
| `rmf` / `rmrf` | `rm -f` / `rm -rf`, without asking |
| `grep` | `grep` with colored matches |
| `chrome`, `firefox`, `safari` | open the browser. A bare domain gets https (`chrome example.com`), a local address gets http (`safari localhost:5173`), and files and full URLs open as they are |
| `telegram` | open Telegram |
| `off` | turn the screen off |
| `szrc` | reload the config: `exec zsh` |

## Functions

| function | what it does |
| --- | --- |
| `up [n]` | go up `n` folders (1 if left out) |
| `mkcddir <dir>` | create a folder, including missing parents, and go into it |
| `gitroot` | go to the top folder of the current git repository |
| `f <text> [dir]` | list the files that contain the text; skips `.git`, `node_modules` and binary files |
| `replace <from> <to>` | replace exact text in every text file below the current folder, and list the files it changed. Review with `git diff` |
| `extract <archive>…` | unpack by extension: zip, tar and its compressed forms, 7z, rar, gz, bz2, xz, zst, Z |
| `port [n]` | show what's listening on TCP port `n`, or on every port |
| `killport <n>` | stop whatever is listening on port `n`: politely first, forcefully after 3 seconds |
| `nr [script]` | list the scripts in the nearest package.json, or run one with npm: `nr dev` |
| `myip` | the local address of each network connection, then your public IP |
| `cls` | clear the screen and the scrollback |
| `tree` | a simple folder tree, until you `brew install tree` |
| `split3 [dir…]` | split this iTerm2 tab into equal columns, one per folder, each already `cd`'d in. With no folders: `~/Code/cognitiveos`, `here4you` and `realtor-doc` |

`port` and `killport` only see your own processes; system services need
`sudo lsof`. `myip` asks api.ipify.org for the public address.

`split3` works in iTerm2 only, not inside tmux, and needs no permissions: it
scripts iTerm2 from inside iTerm2. It checks every folder before splitting,
so a typo leaves your tab as it was. To change the default folders, edit the
`dirs=(…)` line in the function.

All of them are in `custom-functions.zsh`, which opens with a one-line
summary of every function in it.

## Keys

The command line uses emacs-style keys — Ctrl-A start of line, Ctrl-E end,
Ctrl-W delete the word before the cursor — plus:

| key | does |
| --- | --- |
| ↑ / ↓ | previous / next command that starts with what you've typed: type `git`, press ↑ |
| Ctrl-R | search history as you type; `*` and `?` work as wildcards |
| Ctrl-X Ctrl-E | edit the command in `$EDITOR`; save and quit to run it |
| Page Up / Page Down | previous / next command with the same first word |
| ⌥-← / ⌥-→, Ctrl-← / Ctrl-→ | move one word (macOS may use Ctrl-arrows to switch Spaces) |
| Home / End | start / end of the line |
| → or End, at the end of the line | accept the suggestion shown after the cursor |
| ⇧-Tab | previous entry in the completion menu |

`keybindings.zsh` has a comment with the key and its action on every binding.

## Colors

`colors.zsh` holds every color, as one scheme for iTerm2's Solarized Light
preset (background `#fdf6e3`). A color means the same thing wherever it
appears:

| color | on the command line | in the prompt |
| --- | --- | --- |
| green `#449630` | a command that exists, and what you type after it | git branch; `❯` after a command that worked |
| bright green `#3fad1e` | your aliases and functions (bold) | |
| faded green `#87a181` | a command that doesn't exist, and everything after it | untracked files |
| blue `#0068a7` | a file or folder that exists | folders |
| light blue `#5b92bf` | a path you're still typing | shortened parts of a path |
| violet `#462f80` → `#9787d9` | brackets, darkest outermost | `#725abd`: changed files, background jobs, tool versions |
| red `#dc322f` | dangerous commands (below) | conflicts; `❯` and `✘` after a failed command |
| gray `#7d7a75` | text in quotes | the words "on", "took", "at" |
| near-black `#302d29` | quote marks | the OS icon |
| plain `#657b83` | the suggestion after the cursor | command duration, clock |

**Dangerous commands** turn red only where a command starts, so `git add`
isn't mistaken for `dd`: `sudo`, `rm -r` / `rm -f` and the `rmf` / `rmrf`
aliases, `git push --force`, `git reset --hard`, `git clean -f`,
`git branch -D`, `git checkout -- .`, `git restore .`, `chmod -R`, `chown -R`,
`dd`, `mkfs`, `diskutil erase…`, `shutdown`, `reboot`. To add one, extend the
`dangerous` list in `colors.zsh`.

Two of these effects aren't plain settings. `plugins.zsh` adds two small
highlighters: one fades everything after a mistyped command, the other
darkens quote marks. They read internal results of zsh-syntax-highlighting,
so if either stops working after a plugin update, that's the place to look.

Hex colors need a terminal with 24-bit color — iTerm2, VS Code and Cursor all
have it. Anywhere else zsh uses the nearest of the 256 standard colors.

## Prompt

powerlevel10k in its Lean style: one line, no bars. On the left, the OS icon,
the current folder, git status and `❯`; on the right, how the last command
ended, how long it took, and the time.

Git status:

| shows | means |
| --- | --- |
| `⇡2` / `⇣1` | commits to push / to pull |
| `⇢` / `⇠` | the same for the branch you push to, when it isn't the one you pull from |
| `*1` | stashes |
| `+2` | staged changes |
| `!1` | changed files that aren't staged |
| `?3` | untracked files |
| `~1` | conflicts; `merge` or `rebase` while one is in progress |
| `wip` | the last commit's message says wip |

How the last command ended:

| shows | means |
| --- | --- |
| red `❯`, nothing on the right | it failed with an ordinary error code |
| `✘ INT` | you stopped it with Ctrl-C. `TERM` and `KILL` mean it was killed, `HUP` that its terminal closed, `SEGV` that it crashed |
| `✘ 0\|1` | part of a pipe failed; the numbers are each command's exit code |
| `took 4s` | it ran for 3 seconds or more |

### Changing the prompt

- **Small changes** — which parts show, the time format, how paths get
  shortened: edit `p10k.zsh`, then open a new tab or `exec zsh`. `p10k reload`
  isn't enough: it redraws from the settings already loaded and doesn't read
  the file again.
- **A different look** — style, separators, icons: run `p10k configure`. It
  rewrites `p10k.zsh` completely, so commit the result. It leaves `zshrc`
  alone, which already has the lines the wizard looks for.
- **Colors** stay in `colors.zsh` either way. `apply_prompt_colors` applies
  them right after `p10k.zsh` loads, so they survive the wizard.

The prompt only loads in a real terminal. Dumb terminals can't draw it, and in
shells without a terminal — like the `zsh -lic` that IDEs run to read your
environment — its git helper can't start and would print errors.

powerlevel10k itself now has very limited support upstream: no new features,
and most bugs won't be fixed.

## Local settings

Settings for this Mac only — secrets, work paths, a different editor — go in
`~/.zshrc.local`. It's loaded last, so it wins over everything here, and it's
never part of the repo. Create it yourself:

```bash
touch ~/.zshrc.local && chmod 600 ~/.zshrc.local
```

For example:

```zsh
export SOME_API_KEY=...
export EDITOR='cursor --wait'
alias work='cd ~/Code/work-project'
```

Whenever the installer runs, it makes sure the file stays private (mode 600).
