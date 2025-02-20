{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "zap-zsh";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "zap-zsh";
    repo = "zap";
    rev = "release-v1";
    sha256 = ""; # Replace this with the correct hash after running nix-prefetch
  };

  installPhase = ''
    mkdir -p $out/share/zsh
    cp -r $src $out/share/zsh/zap
  '';

  meta = with lib; {
    description = "Minimal Zsh plugin manager";
    homepage = "https://github.com/zap-zsh/zap";
    license = licenses.mit;
  };
}
