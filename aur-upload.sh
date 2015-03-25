#!/bin/bash
BUILDSCRIPT=${1:-PKGBUILD}

yesno() {
	read -p "$1 [y/N] " response
	[[ $response == "y" || $response == "Y" ]] || exit 1
}

if makepkg -f -p "${BUILDSCRIPT}"; then
    if ! source "$BUILDSCRIPT"; then
        echo "Could not source ${BUILDSCRIPT}"
        exit 1
    fi

    echo "Running namcap on ${BUILDSCRIPT}..."
    namcap "$BUILDSCRIPT"

    echo
    echo "Running namcap on package..."
    namcap "${pkgname}-${pkgver}-${pkgrel}-*.pkg.tar.xz"

    yesno "Continue?"

    if mkaurball -fp "${BUILDSCRIPT}"; then
        tmpfile=$(mktemp -t $(basename $0).login.XXXXXX)
        pass archlinux.org/aur | tail -n+2 >> "$tmpfile"
        pass archlinux.org/aur | head -n1 >> "$tmpfile"

        aurploader -anrv -l "$tmpfile" "${pkgname}-${pkgver}-${pkgrel}.src.tar.gz"

        rm -f "$tmpfile"
    fi
fi
