# a visual recursive list of all files and directories
function tree() {
    find . | sed -e 's/[^\/]*\//|--/g' -e 's/-- |/    |/g' | $PAGER
}



# recursive text search (ack is also nifty)
function f() {
    find . -name '*' | xargs grep -l $1
}



# clean screen
function cls {
    osascript -e 'tell application "System Events" to keystroke "k" using command down' 
}



# recursive search and replace (ignoring hidden files and dirs), example: replace foo bar
function replace() {
  find . \( ! -regex '.*/\..*' \) -type f | xargs perl -pi -e "s/$1/$2/g"
}



# cd ../ *arg
function up {
    if [[ "$#" < 1 ]] ; then
        cd ..
    else
        CDSTR=""
        for i in {1..$1} ; do
            CDSTR="../$CDSTR"
        done
        cd $CDSTR
    fi
}



# show spotify current track
zsh_show_spotify_track() {
  state=`osascript -e 'tell application "Spotify" to player state as string'`;
  if [[ $state = "playing" ]]; then
    artist=`osascript -e 'tell application "Spotify" to artist of current track as string'`;
    track=`osascript -e 'tell application "Spotify" to name of current track as string'`;

    echo -n "$artist - $track";
  fi
}



# get the name of the repo i am on
zsh_show_git_repo_name() { 
    gittopdir=$(git rev-parse --git-dir 2> /dev/null)
    if [[ "foo$gittopdir" == "foo.git" ]]; then
        echo `basename $(pwd)`
    elif [[ "foo$gittopdir" != "foo" ]]; then
        echo `dirname $gittopdir | xargs basename`
    fi
}



# show itunes current track
zsh_show_itunes_track() {
    #!/bin/bash

    local state=`osascript -e 'tell application "iTunes" to player state as string'`;
    if [[ $state == "playing" ]];
        then
            local symbol="\uf490"
            artist=`osascript -e'tell application "iTunes"' -e'get artist of current track' -e'end tell'`;
            title=`osascript -e'tell application "iTunes"' -e'get name of current track' -e'end tell'`;

            echo -e "$symbol  $artist - $title"
        else 
            local symbol="\uf497"
            echo "music is off $symbol"
    fi 
}


#intentet signal char
zsh_show_internet_signal(){
  #source on quality levels - http://www.wireless-nets.com/resources/tutorials/define_SNR_values.html
  #source on signal levels  - http://www.speedguide.net/faq/how-to-read-rssisignal-and-snrnoise-ratings-440
  local signal=$(airport -I | grep agrCtlRSSI | awk '{print $2}' | sed 's/-//g')
  local noise=$(airport -I | grep agrCtlNoise | awk '{print $2}' | sed 's/-//g')
  local SNR=$(bc <<<"scale=2; $signal / $noise")

  local net=$(curl -D- -o /dev/null -s http://www.google.com | grep HTTP/1.1 | awk '{print $2}')
  local color='%F{yellow}'
  local symbol="\uf197"

  # Excellent Signal (5 bars)
  if [[ ! -z "${signal// }" ]] && [[ $SNR -gt .40 ]] ; 
    then color='%F{021}' ; symbol="\uf1eb" ;
  fi

  # Good Signal (3-4 bars)
  if [[ ! -z "${signal// }" ]] && [[ ! $SNR -gt .40 ]] && [[ $SNR -gt .25 ]] ; 
    then color='%F{021}' ; symbol="\uf1eb" ;
  fi

  # Low Signal (2 bars)
  if [[ ! -z "${signal// }" ]] && [[ ! $SNR -gt .25 ]] && [[ $SNR -gt .15 ]] ; 
    then color='%F{009}' ; symbol="\uf1eb" ;
  fi

  # Very Low Signal (1 bar)
  if [[ ! -z "${signal// }" ]] && [[ ! $SNR -gt .15 ]] && [[ $SNR -gt .10 ]] ; 
    then color='%F{009}' ; symbol="\uf1eb" ;
  fi

  # No Signal - No Internet
  if [[ ! -z "${signal// }" ]] && [[ ! $SNR -gt .10 ]] ; 
    then color='%F{009}' ; symbol="\uf011";
  fi

  if [[ -z "${signal// }" ]] && [[ "$net" -ne 200 ]] ; 
    then color='%F{009}' ; symbol="\uf011" ;
  fi

  # Ethernet Connection (no wifi, hardline)
  if [[ -z "${signal// }" ]] && [[ "$net" -eq 200 ]] ; 
    then color='%F{021}' ; symbol="\uf197" ;
  fi

  echo -n "%{$color%}$symbol " # \f1eb is wifi bars
}



# extract any time of compressed file
function extract {
    echo Extracting $1 ...
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1  ;;
            *.tar.gz)    tar xzf $1  ;;
            *.bz2)       bunzip2 $1  ;;
            *.rar)       rar x $1    ;;
            *.gz)        gunzip $1   ;;
            *.tar)       tar xf $1   ;;
            *.tbz2)      tar xjf $1  ;;
            *.tgz)       tar xzf $1  ;;
            *.zip)       unzip $1   ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1  ;;
            *)        echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}



# diff char depenging on if git is dirty or clean
function _prompt_char {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  if [[ -n $STATUS ]]; then
    echo "$GIT_DIRTY"
  else
    echo "$GIT_CLEAN"
  fi
}



# get the name of the repo i am on
_git_repo_name() { 
    gittopdir=$(git rev-parse --git-dir 2> /dev/null)
    if [[ "foo$gittopdir" == "foo.git" ]]; then
        echo `basename $(pwd)`
    elif [[ "foo$gittopdir" != "foo" ]]; then
        echo `dirname $gittopdir | xargs basename`
    fi
}



function prompt_char {
    git branch >/dev/null 2>/dev/null && echo "$GIT_DIRTY" && return
    hg root >/dev/null 2>/dev/null && echo "$GIT_DIRTY" && return
    echo "$GIT_CLEAN"
}

