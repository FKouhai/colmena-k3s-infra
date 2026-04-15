let
  epsylon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv3NiE4yau0yssWjamr1eRSfEXHMlwrnMbQaMLJL7Nw";
  worker01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsodbjN8n5+cGgrzv9CzjfZmNg9SC9cVF+2saOlvT/+ root@nixos";
  worker02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXozSZ5kELvFtgABUo01zW57a2Fwr77dAi21uffPFai root@nixos";
  worker03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFBzNrWVUsFMfIDHWcHKpzPmWr6pGCuyPdLqf7o7mTk0 root@worker03";
  worker04 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEecocGFnzgG/u/ZR4avX1YC1m7XGYyo0uyILTWz23Ne root@worker04";
  franky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyWsnvAIM23SRQCW4AIPKeNhVeCWtez/CV1hDegCunC";
in
{
  "k3s-s3-creds.yaml.age".publicKeys = [
    epsylon
    franky
  ];
  "cluster-token.age".publicKeys = [
    epsylon
    franky
    worker01
    worker02
    worker03
    worker04
  ];
}
