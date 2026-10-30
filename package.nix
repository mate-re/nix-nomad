{
  pkgs,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "nomad";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-Cv6fe8AKNuTNAJYmNI6mgxP9NvVzGizZIYbUVVm8Olw=";
  };
  vendorHash = "sha256-d8PfBcwz/7Pi6nRhnKNpRkCDxqXMzw9graSa4AkB76A=";

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
