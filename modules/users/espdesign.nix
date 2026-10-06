{
  den,
  ...
}:
{
  den.aspects.espdesign =
    {
      host ? null,
      ...
    }:
    let
      isDesktop = host == null || (host ? hostName && host.hostName != "valako");
    in
    {
      includes = [
        den.provides.define-user
        den.provides.primary-user
        (den.provides.user-shell "zsh")
        den.aspects.autologin-vm
      ]
      ++ (
        if isDesktop then
          [
            (den.provides.unfree [
              "obsidian"
              "signal-desktop"
              "slack"
              "spotify"
            ])
          ]
        else
          [ ]
      );
      nixos =
        { ... }:
        {
          users.users.espdesign = {
            initialHashedPassword = "$6$kk8o25Zeru3ZiUyL$zoRQ7si4zE2As8pL6D96w/VLktcIF7Zg1Ovn976JitlkQ68LiXKneJ/vMGGR7DAowq7sXqRGQVHRkq2rQ5MTU1";
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVT8QAQNC1TJROywn6DfVEbRmcuTjVlKBar+4OOZZ1S"
            ];
          };
          networking.firewall = {
            enable = true;
          };

        };

      homeManager =
        { pkgs, ... }:
        {
          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;
            settings = {
              "*" = {
                AddKeysToAgent = "yes";
                IdentityFile = "~/.ssh/id_ed25519_main";
              };
            };
          };

          home.packages =
            with pkgs;
            [
              ghostty.terminfo
            ]
            ++ (
              if isDesktop then
                [
                  obsidian
                  signal-desktop
                  slack
                  spotify
                  qbittorrent
                  element-desktop
                ]
              else
                [ ]
            );
          programs.git = {
            enable = true;
            signing.format = null;
            settings = {
              user = {
                name = "espdesign";
                email = "evanpendergraft@gmail.com";
              };

              init = {
                defaultBranch = "main";
              };

              pull = {
                rebase = true;
              };
            };
          };
        };
    };

}
