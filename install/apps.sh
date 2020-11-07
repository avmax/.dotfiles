LOCAL_ROOT=~/.dotfiles/installers
DOWNLOADS=~/Downloads
APPLICATIONS=/Applications
VOLUMES=/Volumes
PREFERENCES=~/Library/Application\ Support

rm -rf $LOCAL_ROOT && mkdir -p $LOCAL_ROOT && cd $LOCAL_ROOT

download_zipped_app()
{
    URL=$1
    NAME=$2

    sudo rm -rf "$APPLICATIONS/$NAME"
    curl -o "$NAME.zip" $URL # -s
    unzip -q "$NAME.zip" -d $NAME
    sudo mv $NAME $APPLICATIONS
}

download_mountable_app()
{
    URL=$1
    NAME=$2

    sudo rm -rf "$APPLICATIONS/$NAME"
    curl -o "$NAME.dmg" $URL # -s
    sudo hdiutil attach "$NAME.dmg" # -quiet
    sudo cp -R "$VOLUMES/$NAME" "$APPLICATIONS/$NAME"
    sudo hdiutil unmount "$VOLUMES/$NAME" # -quiet
}

# FIGMA_URL="https://desktop.figma.com/mac/Figma.zip"
# FIGMA_NAME="Figma"
# download_zipped_app $FIGMA_URL $FIGMA_NAME

# SPECTACLE_URL="https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip"
# SPECTACLE_NAME="Spectacle"
# download_zipped_app $SPECTACLE_URL $SPECTACLE_NAME
# rm -rf "$PREFERENCES/Spectacle/Shortcuts.json" && cp "~/.dotfiles/spectacle/Shortcuts.json" "$PREFERENCES/Spectacle/Shortcuts.json"

# ITERM_URL="https://iterm2.com/downloads/stable/iTerm2-3_1_7.zip"
# ITERM_NAME="iTerm"
# download_zipped_app $ITERM_URL $ITERM_NAME

# UNARCHIVER_URL="https://dl.devmate.com/com.macpaw.site.theunarchiver/TheUnarchiver.zip"
# UNARCHIVER_NAME="unarchiver"
# download_zipped_app $UNARCHIVER_URL $UNARCHIVER_NAME

# VSCODE_URL="https://az764295.vo.msecnd.net/stable/1dfc5e557209371715f655691b1235b6b26a06be/VSCode-darwin-stable.zip"
# VSCODE_NAME="VSCode"
# download_zipped_app $VSCODE_URL $VSCODE_NAME

# SKYPE_URL="https://endpoint920510.azureedge.net/s4l/s4l/download/mac/Skype-8.26.0.70.dmg"
# SKYPE_NAME="Skype"
# download_mountable_app $SKYPE_URL $SKYPE_NAME

# TELEGRAM_URL="https://osx.telegram.org/updates/TelegramMac.dmg"
# TELEGRAM_NAME="Telegram"
# download_mountable_app $TELEGRAM_URL $TELEGRAM_NAME

# WEBSTORM_URL="https://download-cf.jetbrains.com/webstorm/WebStorm-2018.2.dmg"
# WEBSTORM_NAME="WebStorm"
# download_mountable_app $WEBSTORM_URL $WEBSTORM_NAME

# TEAMVIEWER_URL="https://download.teamviewer.com/download/TeamViewer.dmg"
# TEAMVIEWER_NAME="TeamViewer"
# download_mountable_app $TEAMVIEWER_URL $TEAMVIEWER_NAME