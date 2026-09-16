# iTerm2

This Mac's iTerm2 settings, so another Mac can have the same ones.

| file | what it is |
| ---- | ---------- |
| `com.googlecode.iterm2.plist` | the settings, exported from this Mac |
| `export.sh` | update that file from the settings iTerm2 has right now |
| `../_install-scripts/iTerm.sh` | apply the file to a Mac (`./install.sh iTerm`) |

## Install

```bash
./install.sh iTerm
```

**Quit iTerm2 first** (⌘Q) and run it from Terminal.app. iTerm2 keeps its
profiles in memory and writes them back out when it quits, so a running iTerm2
would undo the import. A dry run is fine with iTerm2 open:

```bash
DRY_RUN=1 ./install.sh iTerm
```

The settings land in the `com.googlecode.iterm2` defaults domain and apply the
next time iTerm2 starts. The installer then reads every key back and stops with
an error if any of them did not take.

The font the profiles ask for is *not* installed by this — it is four files
from the powerlevel10k project, see
[zsh/install.md](../zsh/install.md#4-set-up-the-terminal). The installer warns
when it is missing; until then the prompt's icons show as boxes.

## What is in the file

Everything in the `com.googlecode.iterm2` defaults domain except the parts that
describe *this Mac*:

- the profiles (`New Bookmarks`) and which one is the default — colors, font,
  window size, terminal type, scrollback, bell
- the key bindings (`GlobalKeyMap`) and the mouse and trackpad ones
  (`PointerActions`)
- the app-wide settings — Esc feedback, tab behaviour, key repeat, Sparkle's
  update checks

Left out, because they are about the machine rather than the settings:

| dropped | why |
| ------- | --- |
| `NoSync*` | iTerm2's own marker for state it never syncs — install id, window counts, "don't warn me again" answers |
| `NSWindow Frame *`, `NSSplitView Subview Frames*`, `NSToolbar Configuration*`, `NSNavPanel*` | window and panel positions, for this Mac's screens |
| `SUFeedURL`, `SULastCheckTime`, `SUHasLaunchedBefore`, `SUUpdateRelaunchingMarker`, `SUFeedAlternateAppNameKey` | Sparkle's own state; the feed URL carries a per-install shard. The update *settings* are kept |
| `iTerm Version` | the build that last wrote the settings |
| `findMode_iTerm` | the mode last used in the find bar |

Importing **merges**: what the file sets wins, and anything else a Mac already
has — including everything in that table — is left alone.

## After changing a setting in iTerm2

Change it in iTerm2's own settings, then bring the file up to date:

```bash
./iTerm/export.sh
git diff -- iTerm/
```

iTerm2 can stay open; it writes settings into the defaults database as you
change them. The export sorts keys and writes XML, so the same settings always
produce the same file and the diff shows only what actually changed.

Preview first with `DRY_RUN=1 ./iTerm/export.sh` — it prints the difference and
writes nothing.

## Three projects side by side

`split3`, a zsh function, splits the current tab into equal columns and `cd`s
each into a project — see [zsh/readme.md](../zsh/readme.md#functions). It
drives iTerm2 over AppleScript, so it needs nothing from these settings.

## Rolling back

Every install copies the settings it is about to replace into the backup dir:

```bash
ls ~/.dotfiles-backup/                       # pick a timestamp
defaults import com.googlecode.iterm2 \
  ~/.dotfiles-backup/<timestamp>/com.googlecode.iterm2.plist
```

Quit iTerm2 first, for the same reason as the install. This puts back the
values that were replaced; settings that only existed in the repo's file stay,
so to get a truly clean slate use `defaults delete com.googlecode.iterm2`
before the import.
