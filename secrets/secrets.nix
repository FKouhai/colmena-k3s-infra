let
  epsylon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv3NiE4yau0yssWjamr1eRSfEXHMlwrnMbQaMLJL7Nw";
  worker01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzn/nIwm8OkZl0i6WFcyGaOU7pgf9MSyditS9Cb+kGX nixos@worker01";
  worker02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXZUmYfQNSgw5XZ/pZaQQtNnqfFrXCyDa9Z4hRFWmOm nixos@worker02";
  worker03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPScx2ZdYk/hx6K34iAdiUyRHamP9FZMvmeVUbhhC+l nixos@worker03";
  worker04 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDa6oZddfETHuDvGB/rVHYfposYLKEz9wkvObhsRjZnY nixos@worker04";
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
