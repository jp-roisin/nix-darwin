{ hostname, username, ... }:
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  # NetBIOSName write blocked by a stuck com.apple.macl xattr on the SIP-protected
  # plist (defaults exits non-zero, aborting activation). Value is already set to
  # the hostname on-system; re-enable once the xattr can be cleared.
  # system.defaults.smb.NetBIOSName = hostname;

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [ username ];
}
