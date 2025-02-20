{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = ".dotfiles nix dev shell";
  packages = [ pkgs.go ];

  shellHook = ''
    export GOROOT=$(go env GOROOT)
    export GOPATH=$HOME/go
    export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

    # Ensure Mason finds Go where it expects
    sudo mkdir -p /usr/local
    sudo ln -sf $GOROOT /usr/local/go
  '';
}

