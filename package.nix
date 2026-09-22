{
  pkgs,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "nomad";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-JOcN8Xyey84R2oA1lr9f6k/aNY1AJreig3fP3IM9C1M=";
  };
  vendorHash = "sha256-5/ziFzfTgjtvRWCEZoRQMA+1BeAwJwWV9R5C4jSFuPA=";

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
