{ ... }:
{
  den.aspects.virt-manager =
    { user, ... }:
    {
      nixos =
        { ... }:
        {
          virtualisation.libvirtd.enable = true;
          # Enable swtpm (software TPM emulator) to support TPM 2.0 emulation,
          # which is required to run Windows 11 virtual machines.
          # Hinekora works with Passthrough TIS
          virtualisation.libvirtd.qemu.swtpm.enable = true;
          programs.virt-manager.enable = true;
          users.extraGroups.libvirtd.members = [ user.userName ];
        };
    };
}
