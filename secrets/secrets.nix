# secrets/secrets.nix
#
# This file itself is 100% safe to commit — it only lists public keys
# and filenames, never secret material. It tells the `agenix` CLI which
# recipients each encrypted `.age` file should be encrypted for.
#
# Run `cat /etc/ssh/ssh_host_ed25519_key.pub` on the target machine to
# get its key. Only the matching PRIVATE key (root-only, lives at
# /etc/ssh/ssh_host_ed25519_key, never committed) can decrypt.
let
  gsparks-sitespect = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXjL0Izv3aogQkWUKhAAjKez1pul1Uztzc+U/odbKd+ root@nixos";

  # Optional: your own user SSH/age key (e.g. ~/.ssh/id_ed25519.pub),
  # if you want to be able to `agenix -e` and re-encrypt secrets from
  # your regular user account instead of only as root on the host.
  # gsparks-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... REPLACE-ME";

  allKeys = [
    gsparks-sitespect
    # gsparks-user
  ];
in
{
  "oddspedia-privatekey.age".publicKeys = allKeys;
  "oddspedia-psk.age".publicKeys = allKeys;
}
