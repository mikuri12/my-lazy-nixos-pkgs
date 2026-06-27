{
  pname,
  contents,
  aliases ? [],
}: let
  binPattern = builtins.concatStringsSep "|" (["AppRun"] ++ aliases);
in ''
  shopt -s nullglob

  for desktop in ${contents}/*.desktop; do
    install -Dm644 "$desktop" -t $out/share/applications
  done

  for desktop in $out/share/applications/*.desktop; do
    sed -i -E "s#^(Exec=|TryExec=)(${binPattern})([[:space:]].*)?\$#\1${pname}\3#" "$desktop"
  done

  for iconsdir in ${contents}/usr/share/icons ${contents}/share/icons; do
    if [ -d "$iconsdir" ]; then
      mkdir -p $out/share/icons
      cp -rT --no-preserve=mode "$iconsdir" $out/share/icons
    fi
  done

  for png in ${contents}/*.png; do
    install -Dm644 "$png" "$out/share/icons/hicolor/256x256/apps/$(basename "$png")"
  done

  if [ -f ${contents}/.DirIcon ]; then
    for desktop in $out/share/applications/*.desktop; do
      iconname=$(sed -n 's/^Icon=//p' "$desktop" | head -n1)
      if [ -n "$iconname" ] && ! find $out/share/icons -name "$iconname.*" 2>/dev/null | grep -q .; then
        install -Dm644 ${contents}/.DirIcon \
          "$out/share/icons/hicolor/256x256/apps/$iconname.png"
      fi
    done
  fi
''
