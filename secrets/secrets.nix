let
  epsylon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv3NiE4yau0yssWjamr1eRSfEXHMlwrnMbQaMLJL7Nw";
  franky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyWsnvAIM23SRQCW4AIPKeNhVeCWtez/CV1hDegCunC";
in
{
  "k3s-s3-creds.yaml.age".publicKeys = [ epsylon franky ];
}
