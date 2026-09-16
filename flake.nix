{
  description = "gsparks-sitespect NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    cli-music-stream.url = "github:GSSparks/cli-music-stream";
    cli-music-stream.inputs.nixpkgs.follows = "nixpkgs";

    drata.url = "github:ddlees/drata.flake";
    drata.inputs.nixpkgs.follows = "nixpkgs";

    quillai.url = "github:GSSparks/QuillAi";
    # not following nixpkgs — QuillAI tracks its own unstable pin intentionally
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , home-manager
    , agenix
    , cli-music-stream
    , drata
    , quillai
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ./overlays) ];
        config.allowUnfree = true;
      };

      # meet-control.sh promoted to a real flake package (shellcheck'd via
      # writeShellApplication instead of the old inline writeShellScriptBin)
      meet-control = pkgs.callPackage ./packages/meet-control { };

      # Drata agent, patched to fix its desktop entry's exec path
      patched-drata = drata.packages.${system}.default.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/applications/drata-agent.desktop \
            --replace "/opt/Drata Agent/drata-agent" "drata-agent"
        '';
      });
    in
    {
      packages.${system} = {
        inherit meet-control;
      };

      nixosConfigurations.gsparks-sitespect = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/gsparks-sitespect/configuration.nix

          agenix.nixosModules.default

          {
            environment.systemPackages = [
              cli-music-stream.packages.${system}.cli-music-stream
              patched-drata
              quillai.packages.${system}.default
              meet-control
              #aiplaylist-systray.packages.${system}.aiplaylist-systray
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.gsparks = import ./home/gsparks.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      nixosConfigurations."15z-eh000" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/15z-eh000/configuration.nix

          agenix.nixosModules.default

          {
            environment.systemPackages = [
              cli-music-stream.packages.${system}.cli-music-stream
              patched-drata
              quillai.packages.${system}.default
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.gsparks = import ./home/gsparks.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      nixosConfigurations.jellyfin = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/jellyfin/configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations."lenovo-yoga-11e" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/lenovo-yoga-11e/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.gsparks = import ./home/gsparks.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}

