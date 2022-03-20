#!/usr/bin/env bash
# bashsupport disable=BP2001,BP2001
# shellcheck disable=SC2016,SC2028,SC2034

#
# show colors and helper functions output, or generate color lib

. helper.sh
. arrays.bash

e="\033["  # dash needs \033[
_SCRIPT="${0##*/}"

# Suffix for BackGround Colors
#
BACKGROUND="Bg"

# Suffix for Escaped Colors
#
ESCAPED="Esc"

# $FORMAT_COLOR_DEFAULT value will not be a suffix in Variables and Scripts (does not apply for Normal Format)
#
FORMAT_COLOR_DEFAULT="Bold"

# White Formats
#
WHITE=""

# Suffix for Zsh Colors
#
ENCLOSING="Zsh"

# Actions Script Names and Second Argument Value
#
declare -Ag ACTIONS=(["Installing"]="Start" ["Installed"]="Finish")

# Color Names and Values
#
declare -Ag COLORS=()

# Destination Directories and Files
#
declare -Ag DST=(["bin"]="${RC_GENERATED}/bin/${_SCRIPT}" ["lib"]="${RC_GENERATED}/lib/${_SCRIPT}.sh")

# First Argument with Different Format: Bin Name and Format
#
declare -Ag FIRST=(["bin"]="firstother" ["first"]="Bold" ["other"]="Italic")

# Color Formats
#
declare -Ag FORMATS=(["Normal"]=0 ["Bold"]=1 ["BoldItalic"]="3m${e}1" ["Dim"]=2 ["Italic"]=3 ["Under"]=4
  ["Invert"]=7 ["Strike"]=9)

# Color Names
#
declare -ag NAMES=("Black" "Red" "Green" "Yellow" "Blue" "Magenta" "Cyan" "Grey")

# Sorted Keys of Associated Arrays
#
declare -Ag SORTED=(["actions"]="$(printf -- "%s\n" "${!ACTIONS[@]}" | sort)" ["colors"]="" ["symbols"]="")

# Symbol Names and Colors
#
declare -Ag SYMBOLS_COLORS=(
  ["Cube"]="Cyan" ["Critical"]="RedInvert" ["Debug"]="Magenta" ["Division"]="Yellow"
  ["Ellipsis"]="Cyan" ["Error"]="Red" ["Finish"]="Green" ["Harpoon"]="Cyan"
  ["Left"]="Green" ["Minus"]="Red" ["More"]="Magenta" ["Multiply"]="Blue"
  ["Notice"]="Yellow" ["Ok"]="Green" ["Plus"]="Green"
  ["Right"]="Green" ["Start"]="Blue" ["Success"]="Blue"
  ["Tilde"]="Blue" ["Verbose"]="Cyan" ["Warning"]="Yellow"
)

# Symbol Names and Symbol
#
declare -Ag SYMBOLS_ICON=(
  ["Cube"]="❒" ["Critical"]="✘" ["Debug"]="＋" ["Division"]="∕"
  ["Ellipsis"]="…" ["Error"]="✘" ["Finish"]="＞" ["Harpoon"]="⇌"
  ["Left"]="〈" ["Minus"]="-" ["More"]="＞" ["Multiply"]="×"
  ["Notice"]="！""‼" ["Ok"]="✔" ["Plus"]="+"
  ["Right"]="〉" ["Start"]="＞" ["Success"]="◉"
  ["Tilde"]="～" ["Verbose"]="＞" ["Warning"]="‼"
)

# Symbol Names and Prefix Symbol in Normal
#
declare -Ag SYMBOLS_PREFIX=(["Finish"]="=" ["Start"]="=")

# Symbol Names and Text Color
#
declare -Ag SYMBOLS_TEXT=(
  ["Cube"]="${FIRST["bin"]}" ["Critical"]="Red" ["Debug"]="${FIRST["bin"]}" ["Division"]="${FIRST["bin"]}"
  ["Ellipsis"]="CyanDim" ["Error"]="${FIRST["bin"]}" ["Finish"]="${FIRST["bin"]}" ["Harpoon"]="${FIRST["bin"]}"
  ["Left"]="${FIRST["bin"]}" ["Minus"]="${FIRST["bin"]}" ["More"]="${FIRST["bin"]}" ["Multiply"]="${FIRST["bin"]}"
  ["Notice"]="YellowDim" ["Ok"]="${FIRST["bin"]}" ["Plus"]="${FIRST["bin"]}"
  ["Right"]="${FIRST["bin"]}" ["Start"]="${FIRST["bin"]}" ["Success"]="${FIRST["bin"]}"
  ["Tilde"]="${SYMBOLS_COLORS["Tilde"]}" ["Verbose"]="CyanDim" ["Warning"]="${FIRST["bin"]}"
)

# Colorized Symbols Names and Values
#
declare -Ag SYMBOLS=()

# Tmp Directories and Files
#
declare -Ag TMP=(["bin"]="$(mktemp -d)" ["lib"]="$(mktemp)")

#######################################
# generate colors array global with escaped for PS1 and normal
# Globals:
#   ACTIONS
#   COLORS
#   ESCAPE
# Arguments:
#   None
# Escaped:
#   https://github.com/koalaman/shellcheck/wiki/SC2025
#   https://mywiki.wooledge.org/BashFAQ/053
#   Using \[ and \] around colors is necessary to prevent issues with command line editing/browsing/completion!
#   Escaped should not be formatted with "printf '%b'" or "echo -e" and leave it as it is in PS1, so
#   'printf "%s" "\[\e[31m\]"'
#     - Red: '\[\e[31m\]' vs. '\033[31m' or '\e[31m'
#     - Normal: '\[\e[0m\]' or '\[\e(B\e[m\]' vs. '\033[0m' or \e[0m
#   The \[ \] are only special when you assign PS1, if you print them inside a function that runs when the prompt
#   is displayed it doesn't work. In this case you need to use the bytes \001 and \002.
#   prompt() { printf '\001%s\002%s\001%s\002' '\e[33m' message '\e[0m'; }
#   PS1="\$(prompt)\$ "
# Printf:
#   printf '\e[33m%s\e(B\e[m' message
#   printf '\e[33m%s\e[0m' message
#   printf '\033[33m%s\033[0m' message
#   printf '%b' '\e[33m'; printf '%b' message; printf '%b' '\e(B\e[m'
#   printf '%b' '\e[33m'; printf '%b' message; printf '%b' '\e[0m'
#   printf '%b' '\033[33m'; printf '%b' message; printf '%b' '\033[0m'
#######################################
arrays() {
  local color format i=0 key prefix suffix="" symbol value

  for format in "${!FORMATS[@]}"; do
    # \e[0m
    value="${e}${FORMATS["${format}"]}m"
    COLORS["${format}"]="${value}"
  done

  for color in "${NAMES[@]}"; do
    for format in "${!FORMATS[@]}"; do
      suffix=""
      [ "${format}" = "${FORMAT_COLOR_DEFAULT}" ] || suffix="${format}"
      key="${color}${suffix}"
      value="${e}${FORMATS["${format}"]};3${i}m"
      COLORS["${key}"]="${value}"
      COLORS["${key}${BACKGROUND}"]="${e}${FORMATS["${format}"]};4${i}m"
    done
    ((i += 1))
  done

  WHITE="$(sorted white)"
  SORTED["colors"]="$(sorted)"

  for symbol in "${!SYMBOLS_ICON[@]}"; do
    prefix="$(default "${symbol}" SYMBOLS_PREFIX)"
    value="${prefix}${COLORS["${SYMBOLS_COLORS["${symbol}"]}"]}${SYMBOLS_ICON["${symbol}"]}${COLORS["Normal"]}"
    SYMBOLS["${symbol}"]="${value}"
    SYMBOLS["${symbol}${ESCAPED}"]="\[${value}\]"
    SYMBOLS["${symbol}${ENCLOSING}"]="%{${value}%}"
  done

  SORTED["symbols"]="$(printf -- "%s\n" "${!SYMBOLS[@]}" | sort)"
}

#######################################
# generate lib escaped for PS1 and normal
# Globals:
#   BIN_DIR
#   BIN_DIR_TMP
#   BUILD
#   LIB_PATH
#   LIB_PATH_TMP
#   SCRIPT
#   SYM_PATH
#   SYM_PATH_TMP
# Arguments:
#   0
# Escaped:
#   https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
#   https://www.mankier.com/5/terminfo#Description-Predefined_Capabilities
#   man 5 terminfo
#   infocmp $(echo $XTERM)
#   https://github.com/koalaman/shellcheck/wiki/SC2025
#   https://mywiki.wooledge.org/BashFAQ/053
#   Using \[ and \] around colors is necessary to prevent issues with command line editing/browsing/completion!
#   Escaped should not be formatted with "printf '%b'" or "echo -e" and leave it as it is in PS1, so
#   'printf "%s" "\[\e[31m\]"'
#     - Red: '\[\e[31m\]' vs. '\033[31m' or '\e[31m'
#     - Normal: '\[\e[0m\]' or '\[\e(B\e[m\]' vs. '\033[0m' or \e[0m
#   The \[ \] are only special when you assign PS1, if you print them inside a function that runs when the prompt
#   is displayed it doesn't work. In this case you need to use the bytes \001 and \002.
#   prompt() { printf '\001%s\002%s\001%s\002' '\e[33m' message '\e[0m'; }
#   PS1="\$(prompt)\$ "
# Printf:
#   printf '\e[33m%s\e(B\e[m' message
#   printf '\e[33m%s\e[0m' message
#   printf '\033[33m%s\033[0m' message
#   printf '%b' '\e[33m'; printf '%b' message; printf '%b' '\e(B\e[m'
#   printf '%b' '\e[33m'; printf '%b' message; printf '%b' '\e[0m'
#   printf '%b' '\033[33m'; printf '%b' message; printf '%b' '\033[0m'
#######################################
build() {
  local dst changed=false i show tmp super
  super="$(git super "$0")"
  set -eu
  cd "${super}"

  realpath "$0" | grep -q "^${super}" || die Can Only Run from RC Repo
  [ -d "${DST["bin"]}" ] || mkdir -p "${DST["bin"]}"

  cat >"${TMP["lib"]}" <<EOF
# shellcheck shell=sh

#
# Colors library (generated by: ${_SCRIPT})

EOF

  eval "$(awk -F '(' '/^save_.*\(/ { print $1 }' "$0")"

  PATH="${TMP["bin"]}:${PATH}"

  for i in bin lib; do
    dst="${DST["${i}"]}" tmp="${TMP["${i}"]}"
    if ! [ -e "${dst}" ] || ! diff -s "${tmp}" "${dst}" >/dev/null; then
      cmd Installing || show="echo"
      ${show:-Installing} "${_SCRIPT^} ${i^^}"
      if { [ ! -e "${dst}" ] && [ -f "${tmp}" ]; } || { test -f "${dst}" && filehas "${tmp}"; } >/dev/null; then
        cp "${tmp}" "${dst}"
        changed=true
      elif dirhas "${tmp}" 2>/dev/null; then
        rsync -av --delete "${tmp}"/ "${dst}" >/dev/null
        changed=true
      else
        warning "${_SCRIPT^} ${i^^}": Skipped
      fi
      if $changed; then
        git add "${dst}"
        git commit --quiet -m "${_SCRIPT}" "${dst}"
        git push --quiet
        ${show:-Installed} "${_SCRIPT^} ${i^^}"
      fi
    fi
  done
}

#######################################
# show colors and helper functions output
# Globals:
#   COLORS
#   ESCAPE
#   LIB_PATH
#   SYM_PATH
# Arguments:
#   None
#######################################
demo() {
  local action actions array color colors current previous script symbol symbols variable

  for color in ${SORTED[colors]}; do
    current="${color:0:3}"
    if [[ "${color}" =~ ^$(newline-to "${WHITE}" '|^') ]]; then
      current="WHITE-"
    elif [ "${color:0:5}" = "Green" ]; then
      current="${current}-"
    fi
    [ "${current}" = "${previous-}" ] || {
      [ ! "${previous-}" ] || echo
      previous="${current}"
    }

    array="$(printf -- "${COLORS["${color}"]}%s${COLORS["Normal"]}" "${color}")" # from array
    variable="$(printf -- "$(eval echo \$"${color}")%s${Normal}" "${color}")"
    [ "${array}" = "${variable}" ] || {
      echo array: "${array}", variable: "${variable}"
      exit 1
    }

    script="$(${color,,} "${color,,}()")"
    [ "${array}" = "$(${color,,} "${color}")" ] \
      || {
        echo array: "${array}", script: "$(${color,,} "${color}")"
        exit 1
      }

    echo "${array} ${script}"
  done
  echo

  ${FIRST["bin"]} "${FIRST["bin"]}():" "${FIRST["other"]}"
  echo

  for symbol in ${SORTED[symbols]}; do
    ! [[ "${symbol}" =~ ${ESCAPED}$|${ENCLOSING}$ ]] || continue

    array="$(printf -- "${SYMBOLS["${symbol}"]}%s${COLORS["Normal"]}" " ${symbol}")"
    variable="$(printf -- "$(eval echo \$"${symbol}")%s${Normal}" " ${symbol}")"
    [ "${array}" = "${variable}" ] || {
      echo array: "${array}", variable: "${variable}"
      exit 1
    }

    script="$(VERBOSE=1 ${symbol} "${symbol}():" Uses "${FIRST["bin"]}()")"
    printf -- "%s" "${array} ${script}" # Symbol icons have a new line
    echo
  done
  echo

  for action in ${SORTED[actions]}; do
    ${action} "${action}()" "Adds the ':'"
  done
  echo

  DEBUG=1 VAR1="debug(): Function" VAR2=2 debug VAR1
  DEBUG=1 VAR1="debug(): Function" VAR2=2 debug VAR1 VAR2
  DEBUG=1 debug
  VAR1=1 debug
  QUIET=1 DEBUG=1 VAR1=1 debug
  echo

  error "error()": Function
  error
  QUIET=1 error
  echo

  warning "warning()": Function
  warning
  QUIET=1 warning
  echo

  for i in Debug Error Warning; do
    DEBUG=1 $i "${i}" Script
    DEBUG=1 ${i,,} "${i,,}" Function
    echo
  done

  die Die Message
}

#######################################
# actions
# Globals:
#   ACTIONS
#   BIN_DIR_TMP
#   file
#   header
#   if
#   symbol
# Arguments:
#  None
#######################################
save_bin_actions() {
  local i file symbol

  for i in "${!ACTIONS[@]}"; do
    symbol="${ACTIONS["${i}"]}"
    file="${TMP["bin"]}/${i}"
    cat >"${file}" <<EOF
#!/bin/sh

# <html><h2>${i}</h2>
# <h3>Examples</h3>
# <dl>
# <dt>
# Prefix output with ${symbol}, suffix output with ${i} in ${FIRST["other"]} format, and arguments in ${FIRST["first"]}:
# </dt>
# <dd>
# <pre><code class="language-bash">${i} Brew
# </code></pre>
# </dd>
# </dl>
# </html>
${symbol} "\$*:" "${i}"
EOF
    chmod +x "${file}"
  done
}

#######################################
# update colors in files and COLORS array
# Globals:
#   BIN_DIR_TMP
#   BUILD
#   ESCAPE
#   COLORS
#   LIB_PATH_TMP
# Arguments:
#   1   Color Variable Name
#   2   Color Value
#######################################
save_bin_colors() {
  local i file lower
  for i in ${SORTED["colors"]}; do
    lower="${i,,}"
    file="${TMP["bin"]}/${lower}"
    cat >"${file}" <<EOF
#!/bin/sh

# <html><h2>${lower}</h2>
# <h3>Examples</h3>
# <dl>
# <dt>Show arguments with space in ${i}:</dt>
# <dd>
# <pre><code class="language-bash">${lower} Show Text
# </code></pre>
# </dd>
# </dl>
# </html>
[ \$# -eq 0 ] || printf -- '%b' "${COLORS["${i}"]}"; printf '%b' "\$*"; printf -- '%b' "${COLORS[Normal]}"
EOF
    chmod +x "${file}"
  done
}

#######################################
# save executable to show first argument in italic
# Globals:
#   BIN_DIR_TMP
#   FIRST
# Arguments:
#  None
#######################################
save_bin_first() {
  local file first=${FIRST["first"]} other=${FIRST["other"]}
  file="${TMP["bin"]}/${FIRST["bin"]}"
  cat >"${file}" <<EOF
#!/bin/sh

# <html><h2>firstitalic</h2>
# <h3>Examples</h3>
# <dl>
# <dt>
# First Argument in ${first} and rest ${other}:
# </dt>
# <dd>
# <pre><code class="language-bash">${FIRST["bin"]} Show Text
# </code></pre>
# </dd>
# </dl>
# </html>

[ \$# -ne 0 ] || exit 0
first="\$(${first,,} "\$1")"; shift
[ \$# -eq 0 ] || sep=" "
printf -- "\${first}%s\n" "\${sep-}\$(${other,,} "\$@")"
EOF
  chmod +x "${file}"
}

#######################################
# add color symbols variables and executables
# Globals:
#   SYM_PATH_TMP
# Arguments:
#   None
#######################################
save_bin_fromto() {
  local file first="${FIRST["first"]}" name="FromTo" other="${FIRST["other"]}" prefix symbol
  prefix="$(Ok)"
  symbol="$(magenta "=>")"
  file="${TMP["bin"]}/${name}"
  cat >"${file}" <<EOF
#!/bin/sh

# <html><h2>${name}</h2>
# <h3>Examples</h3>
# <dl>
# <dt>
# Prefix: Ok symbol
# 1st argument: ${first} (adds ':')
# 2nd argument: ${other}
# Separator: ${symbol}
# 3rd argument: ${other}
# </dt>
# <dd>
# <pre><code class="language-bash">${name} " :" false true
# </code></pre>
# </dd>
# </dl>
# </html>
[ "\${QUIET-0}" -ne 1 ] || exit \$rc
printf -- '%s' "${prefix} " "\$(${first} "\$1"): " "\$(${other} "\$2") " "${symbol} " "\$(${other} "\$3")"
echo
EOF
  chmod +x "${file}"
}

#######################################
# add color symbols variables and executables
# Globals:
#   SYM_PATH_TMP
# Arguments:
#   None
#######################################
save_bin_symbols() {
  local condition file i symbol format
  for i in ${SORTED["symbols"]}; do
    ! [[ "${i}" =~ ${ESCAPED}$|${ENCLOSING}$ ]] || continue
    case "${i}" in
      Debug) condition='[ "${DEBUG-0}" -eq 1 ] || exit $rc' ;;
      Verbose) condition='[ "${VERBOSE-0}" -eq 1 ] || exit $rc' ;;
      *) condition="" ;;
    esac
    format="${SYMBOLS_TEXT["${i}"]}"
    file="${TMP["bin"]}/${i}"
    symbol="$(printf '%b' "${SYMBOLS["${i}"]}")"
    cat >"${file}" <<EOF
#!/bin/sh

# <html><h2>${symbol}</h2>
# <h3>Examples</h3>
# <dl>
# <dt>
# Show arguments separated with space, prefixed with ${i} symbol.
# $(if [ "${format}" = "${FIRST["bin"]}" ]; then
      echo "First argument in ${FIRST["first"]}, other ${FIRST["other"]}"
    else echo "All arguments in ${format}"; fi):
# </dt>
# <dd>
# <pre><code class="language-bash">${i} Show Text
# </code></pre>
# </dd>
# </dl>
# </html>
rc=\$?
[ "\${QUIET-0}" -ne 1 ] || exit \$rc
${condition}
msg="\$(${format,,} "\$@")"
printf -- '%s' "${symbol}" "\${msg:+ "\${msg}"}"
[ ! "\${msg-}" ] || echo
exit \$rc
EOF
    chmod +x "${file}"
  done
}

#######################################
# save lib
#######################################
save_lib() {
  local i msg symbol
    cat > "${TMP["lib"]}" <<EOF
#!/bin/sh

#
# Colors library (generated by: ${_SCRIPT})

[ ! "\${Bold-}" ] || return 0

EOF

  for i in ${SORTED["colors"]}; do
    tee -a "${TMP["lib"]}" >/dev/null <<EOF
# <html><h2>${i}</h2>
# <p><strong><code>\$${i}</code></strong> Color ${i}.</p>
# </html>
export ${i}="${COLORS["${i}"]}"

EOF
  done

  for i in ${SORTED["symbols"]}; do
    symbol="$(echo "${i}" | sed "s/${ESCAPED}$//;s/${ENCLOSING}$//")"
    if echo "${i}" | grep -q "${ESCAPED}$"; then
      msg="${ESCAPED}"
    elif echo "${i}" | grep -q "${ENCLOSING}$"; then
      msg="${ENCLOSING}"
    else
      msg=""
      tee -a "${TMP["lib"]}" >/dev/null <<EOF
# <html><h2>${symbol} Icon</h2>
# <p><strong><code>\$${i}</code></strong> ${symbol} Icon.</p>
# </html>
export ${symbol}Icon="${SYMBOLS_ICON["${i}"]}"

EOF
    fi

    tee -a "${TMP["lib"]}" >/dev/null <<EOF
# <html><h2>${symbol} ${msg}</h2>
# <p><strong><code>\$${i}</code></strong> ${symbol} ${msg} ${SYMBOLS_COLORS["${symbol}"]}.</p>
# </html>
export ${i}="${SYMBOLS["${i}"]}"

EOF
  done
  chmod +x "${TMP["lib"]}"
}

#######################################
# update colors in files and COLORS array
# Globals:
#   BIN_DIR_TMP
#   BUILD
#   ESCAPE
#   COLORS
#   LIB_PATH_TMP
# Arguments:
#   1   Color Variable Name
#   2   Color Value
#######################################
lib_colors() {
  local i
  for i in ${SORTED["colors"]}; do
    tee -a "${TMP["lib"]}" >/dev/null <<EOF
# <html><h2>${i}</h2>
# <p><strong><code>\$${i}</code></strong> Color ${i}.</p>
# </html>
export ${i}="${COLORS["${i}"]}"

EOF
  done
}

#######################################
# add color symbols variables and executables
# Globals:
#   SYM_PATH_TMP
# Arguments:
#   None
#######################################
lib_symbols() {
  local i msg symbol
  for i in ${SORTED["symbols"]}; do
    symbol="$(echo "${i}" | sed "s/${ESCAPED}$//;s/${ENCLOSING}$//")"
    if echo "${i}" | grep -q "${ESCAPED}$"; then
      msg="${ESCAPED}"
    elif echo "${i}" | grep -q "${ENCLOSING}$"; then
      msg="${ENCLOSING}"
    else
      msg=""
      tee -a "${TMP["sym"]}" >/dev/null <<EOF
# <html><h2>${symbol} Icon</h2>
# <p><strong><code>\$${i}</code></strong> ${symbol} Icon.</p>
# </html>
export ${symbol}Icon="${SYMBOLS_ICON["${i}"]}"

EOF
    fi

    tee -a "${TMP["sym"]}" >/dev/null <<EOF
# <html><h2>${symbol} ${msg}</h2>
# <p><strong><code>\$${i}</code></strong> ${symbol} ${msg} ${SYMBOLS_COLORS["${symbol}"]}.</p>
# </html>
export ${i}="${SYMBOLS["${i}"]}"

EOF
  done
}

#######################################
# sort colors array
# Globals:
#   COLORS
#   NAMES
# Arguments:
#   1
#######################################
sorted() {
  local regex
  regex="$(newline-to "$(printf -- "%s\n" "${NAMES[@]}")" '|')"
  printf -- "%s\n" "${!COLORS[@]}" | grep -vE "${regex}" | sort
  [ "${1-}" = 'white' ] || printf -- "%s\n" "${!COLORS[@]}" | grep -E "${regex}" | sort
}

#######################################
# show colors and helper functions output, or generate color lib
# Globals:
#   BIN_DIR
#   BUILD
#   FIRST
#   LIB_PATH
#   RC
#   RC_PROFILE_D
#   SCRIPT
#   SYM_PATH
# Arguments:
#  None
#######################################
main() {
  local arg func=demo i

  for arg; do
    case "${arg}" in
      build) func="${arg}" ;;
      --*) fromman "$0" "$@" || exit 0 ;;
    esac
  done

  arrays

  for i in "${DST[@]}"; do
    [ -e "${i}" ] || {
      build
      break
    }
  done

  unset Bold

  for i in "${DST[@]}"; do
    [ -d "${i}" ] || [ ! -f "${i}" ] || . "${i}"
  done

  ${func}
}

main "$@"
