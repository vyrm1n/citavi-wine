#!/usr/bin/env bash
set -euo pipefail

export WINEPREFIX="$HOME/.wine-citavi"
export WINEARCH=win64
export WINEDEBUG=-all

URL="https://citavibackoffice.blob.core.windows.net/setup/Citavi7Setup.exe"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

curl -fL --retry 3 -o "$WORK/Citavi7Setup.exe" "$URL"

winetricks -q dotnet48 corefonts

wine "$WORK/Citavi7Setup.exe"

KEY='HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
for arch in 32 64; do
    wine reg add "$KEY" /v Release /t REG_DWORD /d 533320 /f /reg:$arch
    wine reg add "$KEY" /v Version /t REG_SZ /d 4.8.09032 /f /reg:$arch
done

mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/citavi-url-handler.desktop" <<EOF
[Desktop Entry]
Name=Citavi URL Handler
Exec=env WINEPREFIX=$WINEPREFIX WINEDEBUG=-all wine "C:\\\\Program Files (x86)\\\\Citavi 7\\\\bin\\\\Citavi.exe" %u
Type=Application
NoDisplay=true
MimeType=x-scheme-handler/citavi;
EOF

update-desktop-database "$HOME/.local/share/applications"
xdg-mime default citavi-url-handler.desktop x-scheme-handler/citavi
