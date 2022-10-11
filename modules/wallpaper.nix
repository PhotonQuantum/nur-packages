{ config, lib, ... }:

with lib;

{
  options = {
    home.wallpapers = mkOption
      {
        type = with types; listOf path;
        default = [ ];
        example = literalExpression "./wallpaper/wall.heif";
      };
  };
  config = {
    home.activation.wallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] (mkIf (config.home.wallpapers != null)
      (
        let
          f = (idx: wallpaper: "tell desktop ${toString idx} to set picture to \"${wallpaper}\" as POSIX file");
          script = ''
            tell application "System Events"
              ${(concatStringsSep "\n" (imap1 f config.home.wallpapers))}
            end tell
          '';
        in
        ''
          # Set wallpaper.
          echo "setting wallpaper..." >&2

          $DRY_RUN_CMD osascript -e '${script}'
        ''
      ));
  };
}
