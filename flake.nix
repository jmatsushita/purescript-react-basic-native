# {
#   description = "iios";

#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
#     easy-purescript-nix = {
#       url = "github:justinwoo/easy-purescript-nix";
#       flake = false;
#     };
#     flake-utils.url = "github:numtide/flake-utils";
#     flake-compat = {
#       url = "github:edolstra/flake-compat";
#       flake = false;
#     };
#     gitignore = {
#       url = "github:hercules-ci/gitignore.nix";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };

#     # error: NAR hash mismatch in input 'github:nix-community/all-cabal-json/d7c0434eebffb305071404edcf9d5cd99703878e' (/nix/store/lcxiny246z8hvna79rxbzqrm5lw704x5-source), expected 'sha256-r14RmRSwzv5c+bWKUDaze6pXM7nOsiz1H8nvFHJvufc=', got 'sha256-BC2MfQFMnhdwHD/YdAgt5t0PcruFS2N2jG4DSn7CzYk='
#     # all-cabal-json-fix = {
#     #   url = "github:nix-community/all-cabal-json/hackage";
#     #   flake = false;
#     # };
#   };

#   outputs = { self, nixpkgs, easy-purescript-nix, dream2nix, flake-utils, gitignore, ... }@inputs:
#     let
#       name = "iios";

#       systems = [
#         "aarch64-darwin"
#         "x86_64-darwin"
#         "x86_64-linux"
#       ];

#       nixpkgs = dream2nix.inputs.nixpkgs;
#       l = nixpkgs.lib // builtins;

#       forAllSystems = f:
#         l.genAttrs systems (
#           system:
#             f system (nixpkgs.legacyPackages.${system})
#         );


#       d2n-flake = dream2nix.lib.makeFlakeOutputs {
#         inherit systems;
#         config.projectRoot = ./.;
#         source = gitignore.lib.gitignoreSource ./.;
#         projects = ./projects.toml;
#       };

#     # in
#     #   dream2nix.lib.dlib.mergeFlakes [
#     #     d2n-flake
#     #     {
#     #       devShells = forAllSystems (system: pkgs: (l.optionalAttrs (d2n-flake ? devShells)
#     #         {
#     #           default =
#     #             let
#     #               easy-ps = import easy-purescript-nix { inherit pkgs; };
#     #             in
#     #               d2n-flake.devShells.${system}.default.overrideAttrs (old: {
#     #                 buildInputs =
#     #                   old.buildInputs
#     #                   ++ (with easy-ps; [
#     #                   purs
#     #                   purs-tidy
#     #                   psa
#     #                   spago
#     #                   purescript-language-server
#     #                 ]);
#     #               });
#     #         }));
#     #         # let
#     #         #   pkgs = import nixpkgs { inherit system; };
#     #         #   easy-ps = import easy-purescript-nix { inherit pkgs; };
#     #         # in
#     #         # pkgs.mkShell {
#     #         #   inherit name;
#     #         #   buildInputs = (with pkgs; [
#     #         #     nodejs-18_x
#     #         #     nixpkgs-fmt
#     #         #   ]) ++ (with easy-ps; [
#     #         #     purs
#     #         #     purs-tidy
#     #         #     psa
#     #         #     spago
#     #         #     purescript-language-server
#     #         #   ]) ++ (pkgs.lib.optionals (system == "aarch64-darwin")
#     #         #     (with pkgs.darwin.apple_sdk.frameworks; [
#     #         #       Cocoa
#     #         #       CoreServices
#     #         #     ]));
#     #         # });
#     #     }
#     #     {
#     #       # checks.x86_64-linux.prettier = self.packages.x86_64-linux.prettier;
#     #     }
#     #   ];

#         in
#         {
#           devShells = forAllSystems (system: pkgs: (l.optionalAttrs (d2n-flake ? devShells)
#             {
#               default =
#                 let
#                   pkgs = import nixpkgs { inherit system; };
#                   easy-ps = import easy-purescript-nix { inherit pkgs; };
#                 in
#                 pkgs.mkShell {
#                   inherit name;
#                   buildInputs = (with pkgs; [
#                     nodejs-18_x
#                     nixpkgs-fmt
#                   ]) ++ (with easy-ps; [
#                     purs
#                     purs-tidy
#                     psa
#                     spago
#                     purescript-language-server
#                   ]) ++ (pkgs.lib.optionals (system == "aarch64-darwin")
#                     (with pkgs.darwin.apple_sdk.frameworks; [
#                       Cocoa
#                       CoreServices
#                     ]));
#                 });

#             }));
#         }
#         {
#           # checks.x86_64-linux.prettier = self.packages.x86_64-linux.prettier;
#         }
#       ];


# }

{
  description = "iios";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/920bb038e9f0ef9fa5b44814340437a156ba9587";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    easy-purescript-nix = {
      url = "github:justinwoo/easy-purescript-nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, easy-purescript-nix, ... }@inputs:
    let
      name = "core-api";

      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      devShell = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          easy-ps = import easy-purescript-nix { inherit pkgs; };        in
        pkgs.mkShell {
          inherit name;
          buildInputs = (with pkgs; [
            nodejs-18_x
            nixpkgs-fmt
            # nodePackages.firebase-tools
          ]) ++ (with easy-ps; [
            purs
            purs-tidy
            psa
            spago
            purescript-language-server
          ]) ++ (pkgs.lib.optionals (system == "aarch64-darwin")
            (with pkgs.darwin.apple_sdk.frameworks; [
              Cocoa
              CoreServices
            ]));
        });
    };
}
