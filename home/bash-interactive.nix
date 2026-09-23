# home/bash-interactive.nix
#
# The parts of the old .bashrc / .aliases / .aliases_private that are
# genuinely bash logic (functions, PROMPT_COMMAND, the tmux-autostart
# block) rather than simple key=value settings. Home-manager's
# programs.bash has typed options for the simple stuff (see gsparks.nix);
# this file is the escape hatch for everything else, same idea as
# `settings`/`serviceConfig` in the NixOS modules.
#
# This file is shared across every host — nothing SiteSpect-specific
# belongs here (no work VPNs, no ansible-centerprise tooling, no
# gitlab.sitespect.com paths). That lives in a gsparks-sitespect-only
# file instead.
#
# Returns a single string, spliced into programs.bash.initExtra.
{ ... }:

''
  # --- Weather ------------------------------------------------------------
  function __set_location() {
    if [ ! -f ~/.weather_api ]; then
      __set_weather_api
    else
      source ~/.weather_api
    fi

    read -p $'Location needs to be set for the weather function.\x0aEnter your 5-digit zip code: ' zip_code
    read -p $'Please enter your two-digit alphabetic country code: ' country_code
    country_code=$(echo "$country_code" | tr '[:lower:]' '[:upper:]')

    valid_country_code=$(curl -s https://gist.githubusercontent.com/ssskip/5a94bfcd2835bf1dea52/raw/3b2e5355eb49336f0c6bc0060c05d927c2d1e004/ISO3166-1.alpha2.json | jq -r)
    if [[ $valid_country_code != *"$country_code"* ]]; then
      __set_location
    fi

    if [[ $zip_code =~ ^[0-9]{5}$ ]]; then
      DATA=$(curl -s "http://api.openweathermap.org/geo/1.0/zip?zip=$zip_code,$country_code&appid=$API_KEY")
      lattitude=$(echo "$DATA" | jq -r '.lat')
      longitude=$(echo "$DATA" | jq -r '.lon')
      printf "ZIP=%s\nCOUNTRY=%s\nLAT=%s\nLON=%s\n" "$zip_code" "$country_code" "$lattitude" "$longitude" > ~/.weather_location
    else
      echo "Invalid zip code. Please enter a valid 5-digit zip code."
      __set_location
    fi
  }

  function __set_weather_api() {
    read -p $'Please enter your Openweather.org API key: ' api_key
    response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=$api_key")
    if [[ $response =~ "Invalid API key" ]]; then
      echo "Invalid API key. Please enter a valid OpenWeatherMap API key."
      __set_weather_api
    else
      printf "API_KEY=%s\n" "$api_key" > ~/.weather_api
    fi
  }

  function __weather() {
    if [ ! -f ~/.weather_api ]; then
      __set_weather_api
    else
      source ~/.weather_api
    fi

    if [ ! -f ~/.weather_location ]; then
      __set_location
    else
      source ~/.weather_location
    fi

    NOW=$(date +%s)

    if [[ ! -f ~/.weather ]] || [[ $(expr $NOW - $(date -r ~/.weather +%s)) -ge 1800 ]]; then
      DATA=$(curl -m 5 -s "https://wttr.in/$ZIP?format=1")
      BYPASS="True"
      if [[ $? -eq 0 ]] && [[ $DATA != "Unknown location; please try"* ]] && [[ $BYPASS != "True" ]]; then
        TEMP=$(echo "$DATA" | awk -F ' ' '{ print $2 }' | sed 's/+//g')
        COND=$(echo "$DATA" | awk -F ' ' '{ print $1 }')
      else
        DATA=$(curl -m 5 -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY&units=imperial")
        if [[ $? -eq 0 ]]; then
          TEMP=$(echo "$DATA" | jq -r '.main.temp | round')'°F'
          COND=$(echo "$DATA" | jq -r '.weather[0].description')
          if [[ $COND == *"cloud"* ]]; then
            ICON="☁️"
          elif [[ $COND == *"rain"* ]]; then
            ICON="🌧️"
          elif [[ "$COND" == *"snow"* ]]; then
            ICON="❄️"
          else
            ICON="☀️"
          fi
          COND=$ICON
        else
          TEMP="N/A"
          COND="Weather service unavailable"
        fi
      fi
      echo -n $TEMP $COND > ~/.weather
    fi
    cat ~/.weather
  }

  # --- Prompt helpers -------------------------------------------------------
  function __short_wd_cygwin() {
    num_dirs=3
    newPWD="''${PWD/#$HOME/~}"
    if [ $(echo -n $newPWD | awk -F '/' '{print NF}') -gt $num_dirs ]; then
      newPWD=$(echo -n $newPWD | awk -F '/' '{print $1 "/.../" $(NF-1) "/" $(NF) }')
    fi
    echo -n $newPWD
  }

  function __git_dirty() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo -n " 🛠️"
      uncommits=$(git status --porcelain 2>/dev/null| wc -l | tr -d ' ')
      if [[ $uncommits != "0" ]]; then
        echo " $uncommits"
      fi
    fi
  }

  function __git_branch_status {
    local branch_status=$(git rev-parse --abbrev-ref HEAD 2> /dev/null | xargs git rev-parse --symbolic-full-name @{u} 2>&1 || echo "")
    if [[ "$branch_status" == *"no upstream configured for branch"* ]]; then
      branch_status="* $(git rev-parse --abbrev-ref HEAD) *"
    fi
    if [[ "$branch_status" ]]; then
      local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null \
          | awk '{print $1}')
      if [[ $ahead_behind -gt 0 ]]; then
        echo -n "''${branch_status##*/}" | awk '{print substr($0,1,20)}' | awk '{if (length($0)==20) {print $0"..." } else {print $0}}' | tr -d '\n'
        echo -n " ⬇️ $ahead_behind "
      elif [[ $ahead_behind -lt 0 ]]; then
        echo -n "''${branch_status##*/}" | awk '{print substr($0,1,20)}' | awk '{if (length($0)==20) {print $0"..." } else {print $0}}' | tr -d '\n'
        echo -n " ⬆️ $((-ahead_behind)) "
      else
        echo -n "''${branch_status##*/}" | awk '{print substr($0,1,20)}' | awk '{if (length($0)==20) {print $0"..." } else {print $0}}' | tr -d '\n'
        echo -n " 🔁 "
      fi
    fi
  }

  function kontext() {
    local context_file=".kubectl-context"
    local current_dir="$PWD"
    local context

    while [[ "$current_dir" != "/" ]]; do
      if [[ -f "$current_dir/$context_file" ]]; then
        context=$(cat "$current_dir/$context_file")
        kubectl config use-context "$context"
        return
      fi
      current_dir=$(dirname "$current_dir")
    done
  }

  function __dfl_count() {
    dir_count="📁$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)"
    file_count="📄$(find . -mindepth 1 -maxdepth 1 -type f | wc -l)"
    link_count="🔗$(find . -mindepth 1 -maxdepth 1 -type l | wc -l)"
  }

  cd() {
    builtin cd "$@"
    __dfl_count
    kontext
  }

  __dfl_count

  PROMPT_COMMAND=__prompt_command

  __prompt_command() {
    PWD="$PWD"
    EXIT="$?"
    PS1=""

    FG_YELLOW=$(tput setaf 214)
    FG_ORANGE=$(tput setaf 208)
    FG_GREEN=$(tput setaf 106)
    FG_RED=$(tput setaf 167)
    FG_CYAN=$(tput setaf 109)
    FG_GREY=$(tput setaf 245)
    NORM=$(tput sgr0)
    BOLD=$(tput bold)

    PS1+="\n\[$FG_ORANGE\]╭─🐧\[$NORM\]\$(__weather) \[$FG_CYAN\]\[$BOLD\] \d \t \[$NORM\]"
    PS1+="\[$FG_GREY\]\$(__short_wd_cygwin) \[$FG_RED\]"
    PS1+="\$dir_count \$file_count \$link_count "

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      PS1+="\[$FG_YELLOW\]<\[$FG_RED\]\$(__git_dirty)\[$FG_YELLOW\] \$(__git_branch_status)>"
    fi

    PS1+="\n\[$FG_ORANGE\]╰─▶ \u\[$NORM\]@\[$FG_GREEN\]\[$BOLD\]\h\[$NORM\] "

    if [[ $PWD == "/home/gsparks/dev/"* ]]; then
      PS1+="[$(kubectl config get-contexts | grep '*' | awk '{print $2}')] "
    fi

    if [[ -n "$IN_NIX_SHELL" ]]; then
      PS1+="\[$FG_RED\]{nix-shell}\[$NORM\] "
    fi

    if [ $EXIT != 0 ]; then
      if [ $EXIT == 1 ]; then
        PS1+="\[$FG_RED\]:(\[$NORM\] "
      elif [ $EXIT == 2 ]; then
        PS1+="\[$FG_ORANGE\]¯\\_()_/¯\[$NORM\] "
      elif [[ $EXIT == 127 ]]; then
        PS1+="\[$FG_RED\]:|\[$NORM\] "
      elif [ $EXIT == 255 ]; then
        PS1+="\[$FG_ORANGE\]:/\[$NORM\] "
      else
        PS1+="\[$FG_RED\]:(\[$NORM\] "
      fi
    fi
    if [ $EXIT == 0 ]; then
      PS1+="\[$FG_YELLOW\]=)\[$NORM\] "
    fi

    PS1+="¢ "
  }

  # --- Misc utility functions (from .aliases) --------------------------------
  function fix-newline() {
    sed -i 's/\\n/\'$'\n/g' -e 's/\\t/\'$'\t/g' "$*"
  }

  function root-dl {
    if [[ $# -ne 3 ]]; then
      echo "Usage: root-dl <user@remote> <remote_file> <local_file>"
      return 1
    fi

    local ssh_options=""
    if ! ssh -o HostKeyAlgorithms=+ssh-rsa -o BatchMode=yes -o ConnectTimeout=10 "$1" true &>/dev/null; then
      ssh_options="-o HostKeyAlgorithms=+ssh-rsa"
    fi

    ssh -tt $ssh_options "$1" "sudo -S cat '$2'" > "$3"
  }

  function playtube() {
    mpv --ytdl-format=bestaudio ytdl://ytsearch10:"$*"
  }

  function dockerclean() {
    echo "WARNING: This will stop all containers, remove all images, and networks."
    read -p "Are you sure you want to proceed? (Y/N): " confirm

    if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
      echo "Stopping all containers..."
      docker stop $(docker ps -aq)
      echo "Removing all containers..."
      docker rm $(docker ps -aq)
      echo "Removing all images..."
      docker rmi -f $(docker images -aq)
      echo "Removing all networks..."
      docker network rm $(docker network ls -q)
      echo "Removing all files from .docker"
      rm -rf ~/.docker
    else
      echo "Cleanup aborted."
    fi
  }

  # --- Docker-environment aliases ---------------------------------------------
  alias run-nginx='function _run_nginx(){ \
    local net_arg=""; \
    if [ -n "$1" ]; then \
      net_arg="--network $1"; \
    fi; \
    sudo docker run -d --rm --name nginx-server -p 80:80 $net_arg nginx:latest; \
  }; _run_nginx'

  alias colors='for i in {0..255}; do  printf "\x1b[38;5;''${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done'

  alias whois-on-lan='sudo nmap -sP $(ip addr show | grep "wlan0" | grep -E "inet.*brd" | awk "{print $2}" | cut -d "/" -f1 | cut -d "." -f1-3).0/24'

  alias mount-sparky='sshfs garypriscilla@192.168.1.248:/mnt/storage/ /mnt/server -C'

  # --- SSH agent on shell start -----------------------------------------------
  if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add ~/.ssh/id_rsa > /dev/null 2>&1
  fi

  # --- Fabric bootstrap (unmanaged, if present) -------------------------------
  if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then
    . "$HOME/.config/fabric/fabric-bootstrap.inc"
  fi

  # --- pyenv -------------------------------------------------------------------
  # NOTE: the original hardcoded a /nix/store/...-bash-.../bin/bash path,
  # which will break the moment that store path garbage-collects or the
  # bash derivation updates. `pyenv init - bash` lets pyenv figure out the
  # right shell target itself, and is stable across rebuilds.
  eval "$(pyenv init - bash)"

  # --- Interactive tmux autostart ----------------------------------------------
  if [[ -z $TMUX ]]; then
    echo "Please enter the session name: "
    read -r SESSION_NAME

    tmux list-sessions | grep "$SESSION_NAME"

    if [ $? != 0 ]; then
      tmux new-session -d -s "$SESSION_NAME":0 -n "general"
    else
      tmux list-windows -t "$SESSION_NAME" | grep "general"
      if [ $? != 0 ]; then
        tmux new-window -t "$SESSION_NAME":0 -n "general"
      fi
    fi

    tmux attach-session -t "$SESSION_NAME"
  fi

  screenfetch
''
