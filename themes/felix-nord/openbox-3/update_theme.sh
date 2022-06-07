#!/usr/bin/env bash

POLAR_NIGHT_0="#2e3440"
POLAR_NIGHT_1="#3b4252"
POLAR_NIGHT_2="#434c5e"
POLAR_NIGHT_3="#4c566a"

SNOW_STORM_0="#d8dee9"
SNOW_STORM_1="#e5e9f0"
SNOW_STORM_2="#eceff4"

FROST_0="#8fbcbb"
FROST_1="#88c0d0"
FROST_2="#81a1c1"
FROST_3="#5e81ac"

AURORA_0="#bf616a"
AURORA_1="#d08770"
AURORA_2="#ebcb8b"
AURORA_3="#a3be8c"
AURORA_4="#b48ead"

WINDOW_ACTIVE_TITLE_BACKGROUND_COLOR="${POLAR_NIGHT_3}"
WINDOW_ACTIVE_TITLE_FONT_COLOR="#fef0cb"

WINDOW_INACTIVE_TITLE_BACKGROUND_COLOR="${POLAR_NIGHT_3}"
WINDOW_INACTIVE_TITLE_FONT_COLOR="#fef0cb"

MENU_ACTIVE_BACKGROUND_COLOR="${AURORA_2}"
MENU_ACTIVE_FONT_COLOR="${POLAR_NIGHT_3}"

MENU_INACTIVE_BACKGROUND_COLOR="${POLAR_NIGHT_3}"
MENU_INACTIVE_FONT_COLOR="#fcf1ca"

MENU_TITLE_BACKGROUND_COLOR="${POLAR_NIGHT_2}"
MENU_TITLE_FONT_COLOR="#fcf1ca"

MENU_DISABLED_FONT_COLOR="darkgray"

THEME_VARIABLE_NAME_LIST=( 
	WINDOW_ACTIVE_TITLE_BACKGROUND_COLOR
	WINDOW_ACTIVE_TITLE_FONT_COLOR
	WINDOW_INACTIVE_TITLE_BACKGROUND_COLOR
	WINDOW_INACTIVE_TITLE_FONT_COLOR
	MENU_ACTIVE_BACKGROUND_COLOR
	MENU_ACTIVE_FONT_COLOR
	MENU_INACTIVE_BACKGROUND_COLOR
	MENU_INACTIVE_FONT_COLOR
	MENU_TITLE_BACKGROUND_COLOR
	MENU_TITLE_FONT_COLOR
	MENU_DISABLED_FONT_COLOR
	)

THEMERC_PROPERTY_NAME_LIST_WINDOW_ACTIVE_TITLE_BACKGROUND_COLOR=( "window.active.title.bg.color" )
THEMERC_PROPERTY_NAME_LIST_WINDOW_ACTIVE_TITLE_FONT_COLOR=( "window.active.label.text.color" )
THEMERC_PROPERTY_NAME_LIST_WINDOW_INACTIVE_TITLE_BACKGROUND_COLOR=( "window.inactive.title.bg.color" )
THEMERC_PROPERTY_NAME_LIST_WINDOW_INACTIVE_TITLE_FONT_COLOR=( "window.inactive.label.text.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_ACTIVE_BACKGROUND_COLOR=( "menu.items.active.bg.color" "osd.hilight.bg.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_ACTIVE_FONT_COLOR=( "menu.items.active.text.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_INACTIVE_BACKGROUND_COLOR=( "menu.items.bg.color" "osd.unhilight.bg.color" "osd.button.focused.bg.color" "osd.button.pressed.bg.color" "osd.button.unpressed.bg.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_INACTIVE_FONT_COLOR=( "menu.items.text.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_TITLE_BACKGROUND_COLOR=( "menu.title.bg.color" "osd.bg.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_TITLE_FONT_COLOR=( "menu.title.text.color" )
THEMERC_PROPERTY_NAME_LIST_MENU_DISABLED_FONT_COLOR=( "menu.items.disabled.text.color" )

THEMERC_PROPERTY_VALUE_DELIMITER=":"

function escape_sed_pattern(){
	printf "${1}" | sed -e 's/[\\&]/\\&/g' | sed -e 's/[\/&]/\\&/g'
}

function update_line_based_on_prefix(){
	PREFIX_TO_SEARCH="${1}"
	LINE_REPLACEMENT_VALUE="${2}"
	FILE_PATH="${3}"
	if grep -q -E "^${PREFIX_TO_SEARCH}" "${FILE_PATH}"; then
		ESCAPED_PREFIX_TO_SEARCH=$(escape_sed_pattern "${PREFIX_TO_SEARCH}")
		ESCAPED_LINE_REPLACEMENT_VALUE=$(escape_sed_pattern "${LINE_REPLACEMENT_VALUE}")
		sed -i "/^${ESCAPED_PREFIX_TO_SEARCH}/s/.*/${ESCAPED_LINE_REPLACEMENT_VALUE}/" "${FILE_PATH}"
		return 0
	else
		return 1
	fi
}

function key_value_retriever(){
	LINE="${1}"
	if [[ -z "${LINE}" ]]; then
		printf "ERROR: LINE should not be empty\n"
		return
	fi
	KEY_VARNAME="${2}"
	if [[ -z "${KEY_VARNAME}" ]]; then
		printf "ERROR: KEY_VARNAME should not be empty\n"
		return
	fi
	VALUE_VARNAME="${3}"
	if [[ -z "${VALUE_VARNAME}" ]]; then
		printf "ERROR: VALUE_VARNAME should not be empty\n"
		return
	fi
	INDEX_OF_FIRST_EQUAL=$(expr index "${LINE}" :)
	KEY=""
	VALUE=""
	if [[ ${INDEX_OF_FIRST_EQUAL} -ne -1 ]]; then
		KEY="${LINE:0:${INDEX_OF_FIRST_EQUAL} - 1}"
		VALUE="${LINE:${INDEX_OF_FIRST_EQUAL}}"
	fi
	export "${KEY_VARNAME}"="${KEY}"
	export "${VALUE_VARNAME}"="${VALUE}"
}

function apply_template(){
	for THEME_VARIABLE_NAME in "${THEME_VARIABLE_NAME_LIST[@]}"; do
		THEMERC_PROPERTY_NAME_LIST_NAME="THEMERC_PROPERTY_NAME_LIST_${THEME_VARIABLE_NAME}"
		declare -n THEMERC_PROPERTY_NAME_LIST="${THEMERC_PROPERTY_NAME_LIST_NAME}"
		for THEMERC_PROPERTY_NAME in "${THEMERC_PROPERTY_NAME_LIST[@]}"; do
			printf "%-40s%-50s%-40s\n" "${THEMERC_PROPERTY_NAME}" "${THEME_VARIABLE_NAME}" "${!THEME_VARIABLE_NAME}"
			update_line_based_on_prefix "${THEMERC_PROPERTY_NAME}${THEMERC_PROPERTY_VALUE_DELIMITER}" "${THEMERC_PROPERTY_NAME}${THEMERC_PROPERTY_VALUE_DELIMITER} ${!THEME_VARIABLE_NAME}" themerc
		done
	done
}

function generate_themerc_html_overview(){
	FILE_PATH="${1}"
	HTML_OVERVIEW="<html><style>table,th,td{border:1px solid black;border-collapse:collapse;} td{padding:5px;}</style>"
	HTML_OVERVIEW+="<table><tr><th>Key</th><th>Value</th></tr>"
	while IFS= read -r LINE; do
		if [[ ! -z "${LINE}" ]]; then
			key_value_retriever "${LINE}" "LINE_KEY" "LINE_VALUE"
			if [[ ! -z "${LINE_KEY}" ]]; then
				HTML_OVERVIEW+="<tr>"
				HTML_OVERVIEW+="<td>${LINE_KEY}</td>"
				
				# If key ends with '.color' then render the color
				if [[ "${LINE_KEY}" == *.color* ]]; then
					HTML_OVERVIEW+="<td><span style=\"display:inline-block;width:120px;height:40px;background-color:${LINE_VALUE};\">&nbsp;</span> ${LINE_VALUE}</td>"
				else
					HTML_OVERVIEW+="<td>${LINE_VALUE}</td>"
				fi
				
				HTML_OVERVIEW+="</tr>"
			fi
		fi
	done < "${FILE_PATH}"
	HTML_OVERVIEW+="</table></html>"
	echo "${HTML_OVERVIEW}" >"${FILE_PATH}.overview.html"
}

cat themerc | sort | uniq > themerc.sorted
rm -f themerc
mv themerc.sorted themerc
apply_template
generate_themerc_html_overview themerc
openbox --reconfigure

