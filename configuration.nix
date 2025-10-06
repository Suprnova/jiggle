# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <home-manager/nixos>
    <nixos-wsl/modules>
  ];

  environment.systemPackages = with pkgs; [
    ffmpeg
    wget
  ];

  # vscode remote compatibility
  # https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  programs.nix-ld.enable = true;

  programs.nano = {
    enable = true;
    nanorc = ''
      set tabstospaces
      set tabsize 2
    '';
  };

  # zsh config
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  wsl.enable = true;
  wsl.defaultUser = "nova";
  wsl.wslConf.network.hostname = "jiggle";

  users.users.nova.isNormalUser = true;
  users.users.nova.useDefaultShell = true;

  home-manager.users.nova = { pkgs, ... }: {
    home.stateVersion = "25.05";
    home.username = "nova";
    
    # ssh
    programs.ssh.enable = true;
    services.ssh-agent.enable = true;

    # git
    programs.git = {
      enable = true;
      userName = "Suprnova";
      userEmail = "nova@suprnova.dev";
      extraConfig = {
        # rename master to main
        init = {
            defaultBranch = "main";
        };
        # crlf stuff
        core = {
            autocrlf = "input";
        };
        # force ssh on http for github
        url = {
          "ssh://git@github.com/" = {
            insteadOf = "https://github.com/";
          };
        };
      };
    };

    # zsh
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        switch = "sudo nixos-rebuild switch";
        # quick little ditty to open a dev shell based on current directory's shell.nix
        # then open host's vscode with the file "{parent-dir}.code-workspace"
        dev = "nix-shell --run \"code \${PWD##*/}.code-workspace\"";
      };

      initContent = ''
        # required starship config
        eval "$(starship init zsh)"

        # for creating dev environments with nix-shell & vscode
        function initdev() {
          cp "/etc/nixos/dev/''${1}/''${1}.code-workspace" ./''${PWD##*/}.code-workspace
          cp "/etc/nixos/dev/''${1}/shell.nix" .
        }
      '';
    };

    # starship
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
      };
    };

    # yt-dlp
    programs.yt-dlp = {
      enable = true;
      /*
        authenticate with YouTube on firefox, then run "yt-dlp --cookies-from-browser firefox --cookies ~/.config/.yt-dlp-cookies"
      */
      extraConfig = ''
        -f "bv+ba/b"
        --merge-output-format mp4
        --audio-format mp3
        -o ~/videos/%(title).200B.%(ext)s
        --cookies ~/.config/.yt-dlp-cookies
      '';
    };

    # firefox
    programs.firefox.enable = true;
  };
    
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
