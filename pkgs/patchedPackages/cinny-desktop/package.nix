{
  lib,
  pkgsOriginal,
}:
pkgsOriginal.cinny-desktop.overrideAttrs (
  final: prev: {
    patches = (prev.patches or [ ]) ++ [
      ./desktop-notification.patch
    ];

    passthru = lib.attrsets.removeAttrs (prev.passthru or { }) [ "updateScript" ];
  }
)
