let
  epsylon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH2l99ftWZzjuzfxrQXCiOBB0LgvOITRdXsMhdc+uwdv";
  worker01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsodbjN8n5+cGgrzv9CzjfZmNg9SC9cVF+2saOlvT/+ root@nixos";
  worker02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXozSZ5kELvFtgABUo01zW57a2Fwr77dAi21uffPFai root@nixos";
  worker03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrgLbOAcAhfwWeGswdrHU0rTpeKGGK6zHLNr69JkOP8";
  worker04 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzNtDc6WjN4dqa97kqZnXBlJKI8Ia225Z9fT36IDSKq";
  worker05 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5PUBhb0OUgUsuEehNr3i+rblWBHtkkv3X0BXsDPXNn root@nixos";
  franky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyWsnvAIM23SRQCW4AIPKeNhVeCWtez/CV1hDegCunC";
in
{
  "k3s-s3-creds.yaml.age".publicKeys = [
    epsylon
    worker05
    franky
  ];
  "cluster-token.age".publicKeys = [
    epsylon
    worker05
    franky
    worker01
    worker02
    worker03
    worker04
  ];
}
