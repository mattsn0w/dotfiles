#!/bin/bash

set -e

FONTS=("UbuntuMono.zip" "ShareTechMono.zip" "Hack.zip" "JetBrainsMono.zip" "FiraMono.zip" "CascadiaMono.zip")


USER_FONTS="${HOME}/.local/share/fonts"
if [ ! -d "${USER_FONTS}" ]; then
    mkdir -p "${USER_FONTS}"
fi

#cp *zip "${USER_FONTS}"/
cd "${USER_FONTS}"

for FONT_DL in ${FONTS[@]} ; do
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/${FONT_DL}
done

for FONTZIP in $(ls *.zip); do
    # always overwrite without prompting.
    unzip -o "${FONTZIP}"
    rm -f "${FONTZIP}"
done

fc-cache -fv
