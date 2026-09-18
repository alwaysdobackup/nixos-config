# PLACEHOLDER. Do not use this as-is.
#
# Once disko has partitioned and mounted your disk (see README.md, step 2),
# generate the real version of this file with:
#
#   nixos-generate-config --no-filesystems --root /mnt
#
# `--no-filesystems` is important: disko already defines fileSystems.* from
# disko.nix, so you don't want nixos-generate-config's guesses to conflict
# with them. What you DO want from the generated file is everything else:
# boot.initrd.availableKernelModules, boot.kernelModules,
# boot.extraModulePackages, nixpkgs.hostPlatform, and CPU microcode.
#
# Copy the generated /mnt/etc/nixos/hardware-configuration.nix over this
# file before running `nixos-install`.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # e.g. "x86_64-linux"
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Uncomment the line matching your CPU:
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
