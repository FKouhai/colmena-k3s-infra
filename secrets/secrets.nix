let
  epsylon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAJvbUOsV3cQoQqLoYtWC+D5iK/jJQSv5hGUncMchNH";
  worker01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsodbjN8n5+cGgrzv9CzjfZmNg9SC9cVF+2saOlvT/+ root@nixos";
  worker02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXozSZ5kELvFtgABUo01zW57a2Fwr77dAi21uffPFai root@nixos";
  worker03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvGxL7f4+s2a0u8xeMUz/DJPMQqp1wao0vtKd6k18CT";
  worker04 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2rton5QkrU9wsqod0IXWxxEU+PXZwLazRj6kOuZtC9";
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
