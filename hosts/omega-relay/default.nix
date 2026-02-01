{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./firewall.nix
    ./disko.nix
    ./vm.nix
    ./hardware-configuration.nix
    ../../services/mysql.nix
    ../../services/email.nix
    ../../services/vaultwarden.nix
    ../../services/uptimekuma.nix
    ../../services/freshrss.nix
    ../../services/wakapi.nix
  ];

  addons = {
    desktop.hyprland.enable = lib.mkForce false;
    # desktop.cosmic.enable = lib.mkForce false;
    desktop.xfce.enable = lib.mkForce false;

    gpg.enable = true;
  };
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };

  environment.systemPackages = with pkgs; [
    lynx
    chawan
  ];

  wilkuu.services =
    let
      isVM = config.addons.virtualisation.isTestVM;
    in
    {
      stalwart = {
        enable = true;
        domain = if isVM then "mail.omega-relay.local" else "mail.wilkuu.xyz";
        doACME = !isVM;
      };

      vaultwarden = {
        enable = true;
        signupWhitelist = [
          "wilkuu.xyz"
          "omega-relay.local"
        ];
        backupDir = "/srv/data/vaultwarden";
        domain = if isVM then "vaultwarden.omega-relay.local" else "vaultwarden.wilkuu.xyz";
        doACME = !isVM;
      };
      uptimekuma = {
        enable = true;
        domain = if isVM then "uptime.omega-relay.local" else "uptime.wilkuu.xyz";
        dataDir = "/srv/data/uptimekuma";
        doACME = !isVM;
      };
      freshrss = {
        enable = true;
        domain = if isVM then "rss.omega-relay.local" else "rss.wilkuu.xyz";
        doACME = !isVM;
      };
      wakapi = {
        enable = false;
        domain = if isVM then "wakapi.omega-relay.local" else "wakapi.wilkuu.xyz";
        doACME = !isVM;
      };
    };

  # TODO: Make a nginx module
  security.acme = lib.mkIf (!config.addons.virtualisation.isTestVM) {
    acceptTerms = true;
    defaults.email = "jakub@wilkuu.xyz";
  };
  services.nginx =
    let
      isVM = config.addons.virtualisation.isTestVM;
      domain = if isVM then "omega-relay.local" else "wilkuu.xyz";
    in
    {
      enable = true;
      virtualHosts."${domain}" = {
        enableACME = !isVM;
        addSSL = !isVM;
        locations."/" = {
          root = "/srv/www/wilkuu.xyz/";
          index = "index.html";
          tryFiles = "$uri $uri/ =404";
        };
      };
    };

  networking.hostName = "omega-relay";
  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "wilkuu" ];
      X11Forwarding = false;
      PermitRootLogin = "no";
      PrintMotd = true;
    };
  };

}
