{
  pkgs,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "nomad";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-x0DP2F6Iko1q+OdwNBHeX5pGnR9/Fwe4U2kcSihFyp0=";
  };
  vendorHash = "sha256-J8zt2eEdRqu/tpYvfvgPRaa/cCJfUvqf6HNEfbvk0l4=";

  subPackages = [ "." ];
  tags = [ "ui" ];
  ldflags = [
    "-X github.com/hashicorp/nomad/version.Version=${version}"
    "-X github.com/hashicorp/nomad/version.VersionPrerelease="
    "-X github.com/hashicorp/nomad/version.BuildDate=1970-01-01T00:00:00Z"
  ];

  postInstall = ''
    echo "complete -C $out/bin/nomad nomad" > nomad.bash
    installShellCompletion nomad.bash
  '';
  doCheck = false;

  buildInputs = with pkgs; [
    go
    git
  ];
  nativeBuildInputs = with pkgs; [ installShellFiles ];
}
