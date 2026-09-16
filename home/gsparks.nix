# home/gsparks.nix
#
# home-manager config for gsparks. Split into:
#   - native home-manager options below, for anything it has a typed
#     option for (history settings, shopts, aliases, env vars)
#   - ./bash-interactive.nix, for the genuinely custom bash logic
#     (prompt, weather, tmux autostart) ported from the old .bashrc/.aliases
{ pkgs, config, ... }:
let
  # yt-dlp wrapped so it always finds the bgutil PO Token plugin on
  # PYTHONPATH, without needing it exported manually per-shell. Fixes
  # YouTube's PO Token requirement (403s / "Requested format is not
  # available") — see https://github.com/yt-dlp/yt-dlp/issues/12482.
  #
  # Requires the bgutil-provider server running on 127.0.0.1:4416.
  # That's an OCI container, which home-manager can't own — declare it
  # in the NixOS system config instead:
  #   virtualisation.oci-containers.containers.bgutil-provider = {
  #     image = "docker.io/brainicism/bgutil-ytdlp-pot-provider:1.3.2";
  #     ports = [ "127.0.0.1:4416:4416" ];
  #     autoStart = true;
  #   };
  yt-dlp-with-pot = pkgs.symlinkJoin {
    name = "yt-dlp-with-pot";
    paths = [ pkgs.yt-dlp ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/yt-dlp \
        --set PYTHONPATH "${pkgs.python313Packages.bgutil-ytdlp-pot-provider}/lib/python3.13/site-packages"
    '';
  };
in
{
  home.username = "gsparks";
  home.homeDirectory = "/home/gsparks";
  home.stateVersion = "25.05";

  # --- Environment variables (was scattered `export` lines in .bashrc) ------
  home.sessionVariables = {
    VISUAL = "vim";
    EDITOR = "vim";
    TERM = "xterm-256color";
    OP_ACCOUNT = "my.1password.com";
    PYENV_ROOT = "$HOME/.pyenv";
    HISTTIMEFORMAT = "[%F %T] ";
  };

  home.sessionPath = [
    "$HOME/.local/bin"    # was the pipx PATH addition
    "$HOME/.pyenv/bin"
  ];

  # --- Git -------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      user.name = "Gary Sparks";
      user.email = "garypriscillasparks@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # --- Chromium ---------------------------------------------------------
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--disable-features=AudioServiceOutOfProcess"
    ];
  };

  # --- Bash -------------------------------------------------------------
  programs.bash = {
    enable = true;

    historyControl = [ "ignoreboth" "erasedups" ];
    historySize = 10000;
    historyFileSize = 10000;

    shellOptions = [
      "histappend"
      "checkwinsize"
      "cdspell"
      "direxpand"
    ];

    # Simple 1:1 aliases lifted straight from .aliases. A few were dropped
    # or changed — see notes below the block.
    shellAliases = {
      grep = "grep --color=auto";
      cat = "cat";
      ".." = "cd ..";
      "..." = "cd ../..";
      digs = "dig +short NS";
      mkdir = "mkdir -pv";
      refresh = "clear; history -a; source $HOME/.bashrc";
      ports = "ss -tulanp";
      pbcopy = "xsel --clipboard --input";
      pbpaste = "xsel --clipboard --output";
      "wcofun-dl" = ''docker run -it -v "$(pwd)":/downloads wcofun-dl'';
      rm = "rm -I --preserve-root";
      mv = "mv -i";
      cp = "cp -i";
      ln = "ln -i";
      op = "/run/wrappers/bin/op"; # NixOS setuid wrapper path — matches programs._1password
      gitop = "cd `git rev-parse --show-toplevel`";
      dict = "dict -d wn";
      play951 = "mpv https://ice64.securenetsystems.net/WAJI?playSessionID=8882F088-FBC7-F008-2C64ACB2C771047E";
      play1039 = "mpv https://prod-54-90-118-66.amperwave.net/adamsradio-wwfwfmaac-ibc1?";
      play80s = "mpv http://streams.80s80s.de/web/mp3-192/streams.80s80s.de/";
      playnumetal = "mpv http://stream.revma.ihrhls.com/zc9483";
      playoldies = "mpv http://46.105.122.141:9676/;";
      playvinyl = "mpv https://icecast.walmradio.com:8443/classic";
      playcountry = "mpv http://185.33.21.112/ccountry_mobile_mp3";
      playbluegrass = "mpv https://ice24.securenetsystems.net/WAMU";
      play90s90s = "mpv http://streams.90s90s.de/grunge/mp3-192/streams.90s90s.de/";
    };

    # Everything that isn't a simple alias/setting — functions, prompt,
    # tmux autostart, ssh-agent, pyenv init.
    initExtra = import ./bash-interactive.nix { };
  };

  # ls was `alias ls='ls -la --color=auto'` in the original — using the
  # real eza/exa-style program option instead of a raw alias is the more
  # idiomatic home-manager way, but if you want the exact original
  # behavior, drop this block and add `ls = "ls -la --color=auto";` to
  # shellAliases above instead.
  # programs.eza.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # --- yt-dlp / aria2 (used by the playXXX aliases and playtube) -------
  programs.yt-dlp = {
    enable = true;
    package = yt-dlp-with-pot;
    settings = {
      downloader = "aria2c";
      # See https://wiki.archlinux.org/title/Aria2#Changing_the_User_Agent
      # I tried changing the user agent but it still didn't work.
      downloader-args = "aria2c:'-c -j 3 -x 3 -s 3 -k 1M'";
      format = "bestvideo+bestaudio/best";
    };
  };

  # Aria2 in yt-dlp manages itself.
  # If you enable this, ~/.config/aria2/config will
  # be created which interferes with other yt-dlp or something.
  programs.aria2 = {
    enable = true;
    settings = {
      continue = true;
      dir = "${config.xdg.userDirs.download}";
      file-allocation = "none";
      max-connection-per-server = 4;
      min-split-size = "5M";
      log-level = "warn";
    };
  };

  programs.vim = {
    enable = true;
    extraConfig = ''
      set number
      set expandtab
      set shiftwidth=2
      set tabstop=2
    '';
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    keyMode = "vi";
    mouse = true;
    extraConfig = builtins.readFile ./tmux-extra.conf;
  };

  home.file.".local/bin/vpn_status" = {
    executable = true;
    text = ''
      #!/bin/bash

      if pgrep -f "openvpn.*corp1" > /dev/null; then
        corp1="corp1"
      fi
      if pgrep -f "openvpn.*fw1" > /dev/null; then
        fw1="fw1"
      fi

      echo "$corp1  $fw1"
    '';
  };

  home.packages = with pkgs; [
    xsel      # used by pbcopy/pbpaste aliases
    dict      # used by the `dict` alias
    nmap      # used by whois-on-lan
  ];

  programs.home-manager.enable = true;
}
