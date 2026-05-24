{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3b9b849d-3471-4497-84ee-01d20a242988";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AD7B-0DD5";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/509e98f7-0bed-462c-80fd-b7445f7a5386";
    fsType = "ext4";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/ad9fbb99-41e9-4bfd-b6d0-85e1127e8151";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6ee56abd-707f-45d0-9b85-c28d7603c023"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Use unfree kernel driver for improved game support;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.xone.enable = true;
}
