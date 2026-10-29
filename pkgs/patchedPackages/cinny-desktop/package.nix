{
  lib,
  pkgsOriginal,
  gst_all_1,
  stdenv,
}:
pkgsOriginal.cinny-desktop.overrideAttrs (
  final: prev: {
    patches = (prev.patches or [ ]) ++ [
      ./desktop-notification.patch
    ];

    buildInputs =
      (prev.buildInputs or [ ])
      ++ (lib.optionals stdenv.hostPlatform.isLinux [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-libav
      ]);

    passthru = lib.attrsets.removeAttrs (prev.passthru or { }) [ "updateScript" ];
  }
)
