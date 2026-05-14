{ ... }:
{
  den.aspects.hardened-server = {
    nixos =
      { ... }:
      {
        services.fail2ban = {
          enable = true;
          maxretry = 5;
          ignoreIP = [
            "192.168.1.0/24"
            "192.168.86.0/24"
            "10.0.0.0/8"
            "172.16.0.0/12"
          ]; # Whitelist your LAN
        };

        boot.kernel.sysctl = {
          # TCP SYN Cookies — protects against SYN flood attacks
          "net.ipv4.tcp_syncookies" = 1;
          # Ignore ICMP redirects — prevents malicious routing
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.default.accept_redirects" = 0;
          "net.ipv4.conf.all.secure_redirects" = 0;
          "net.ipv4.conf.default.secure_redirects" = 0;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "net.ipv6.conf.default.accept_redirects" = 0;
          # Ignore source-routed packets — prevents IP spoofing
          "net.ipv4.conf.all.accept_source_route" = 0;
          "net.ipv4.conf.default.accept_source_route" = 0;
          "net.ipv6.conf.all.accept_source_route" = 0;
          "net.ipv6.conf.default.accept_source_route" = 0;
          # Reverse-path filter — protects against IP spoofing
          "net.ipv4.conf.all.rp_filter" = 1;
          "net.ipv4.conf.default.rp_filter" = 1;
          # Log martian packets — suspicious source addresses
          "net.ipv4.conf.all.log_martians" = 1;
          "net.ipv4.conf.default.log_martians" = 1;
          # Ignore ICMP echo broadcasts — smurf attack protection
          "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
          # Ignore bogus ICMP error responses
          "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        };

        security.apparmor.enable = true;
      };
  };
}
