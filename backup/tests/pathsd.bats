#!/usr/bin/env bats
# shellcheck disable=SC2001

setup_file() {
  . "${BATS_TEST_DIRNAME}/helpers/load_profile.bash"
  paths="$(eval echo \""$(cat "${RC_PATHS_D}"/* /etc/paths.d/* 2>/dev/null)"\" | awk 'NF')"

  manpaths_exists="$(to_exists "$(awk '/\/bin$/ {gsub(/\/bin$/,"/share/man"); print}' <<<"${paths}")")"
  export manpaths_exists

  infopaths_exists="$(to_exists "$(awk '/\/bin$/ {gsub(/\/bin$/,"/share/info"); print}' <<<"${paths}")")"
  export infopaths_exists
}

to_exists() { tr '\n' '\0' <<< "$1" | xargs -0 -n1 -I {} find "{}" -mindepth 0 -maxdepth 0 -type d 2>/dev/null || true;}

@test "$(description::file exists and in \$PATH)" {
  while read -r line; do
    [[ "${PATH}" =~ ${line} ]]
  done < <(to_exists "${paths}")
}

@test "$(description::file \$PATH in order)" {
  [[ "${PATH}" = *$(newline-to "${paths_exists}" '*:')* ]]
}

@test "$(description::file cyan pathsd in order)" {
  (
    eval "$(pathsd)"
    [[ "${PATH}" = *$(newline-to "${paths_exists}" '*:')* ]]
  )
}

@test "$(description::file cyan \$MANPATH in order)" {
  [[ "${MANPATH}" = *$(newline-to  "${manpaths_exists}" '*:')*: ]]
}

@test "$(description::file \$INFOPATH in order)" {
  [[ "${INFOPATH}" = *$(newline-to  "${infopaths_exists}" '*:')*: ]]
}

