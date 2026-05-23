{ den, ... }:
{
  den.aspects.scripts = {
    includes = [
      den.aspects.scripts.provides.update-all
      den.aspects.scripts.provides.update-notifier
    ];
  };
}
