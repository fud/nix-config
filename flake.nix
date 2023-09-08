{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, disko, ... }@attrs: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    nixosConfigurations.fusion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ({ modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            disko.nixosModules.disko
          ];

          networking.hostId = "51a5861e";
          disko.devices = import ./disks.nix { lib = nixpkgs.lib; };

          boot = {
            swraid.enable = true;
            loader = {
              grub = {
                efiSupport = true;
                efiInstallAsRemovable = true;
                device = "nodev";
              };
            };
          };
          services.openssh.enable = true;

          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFANqxKsQzD00spT2M+Op7n8/8Bd+I9q6umyL7RuVWWx billsb@m1"
          ];
        })
      ];
    };
  };
}
