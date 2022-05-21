#!/usr/bin/env bash

THEMES_DIRECTORY="${HOME}/.local/share/themes"
if [[ -d "${THEMES_DIRECTORY}" ]]; then
	mkdir -p "${THEMES_DIRECTORY}"
fi
cp -r themes/* "${THEMES_DIRECTORY}"
