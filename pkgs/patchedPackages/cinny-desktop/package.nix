{
  pkgsOriginal,
}:
pkgsOriginal.cinny-desktop.overrideAttrs (final: prev: {
  patches = (prev.patches or []) ++ [
    ./desktop-notification.patch
  ];
})
