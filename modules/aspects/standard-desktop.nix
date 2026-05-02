{ den, ... }:
{
  den.aspects.standard-desktop = {
    includes = [
      den.aspects.gnome
      den.aspects.pipewire-sound
      den.aspects.vm
      den.aspects.cups-print
    ];
  };
}
