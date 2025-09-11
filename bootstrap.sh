_bootstrap_abspath () {
  $(command -v python3 || command -v python2 || command -v python) -c "import os.path; print(os.path.abspath('$@'))"
}

# Shell: bash.
if test -n "$BASH"; then
  _PW_BOOTSTRAP_PATH="$(_bootstrap_abspath "$BASH_SOURCE")"
# Shell: zsh.
elif test -n "$ZSH_NAME"; then
  _PW_BOOTSTRAP_PATH="$(_bootstrap_abspath "${(%):-%N}")"
# Shell: dash.
elif test ${0##*/} = dash; then
  _PW_BOOTSTRAP_PATH="$(_bootstrap_abspath \
    "$(lsof -p $$ -Fn0 | tail -1 | sed 's#^[^/]*##;')")"
# If everything else fails, try $0. It could work.
else
  _PW_BOOTSTRAP_PATH="$(_bootstrap_abspath "$0")"
fi

# Check if this file is being executed or sourced.
_pw_sourced=0
if [ -n "$SWARMING_BOT_ID" ]; then
  # If set we're running on swarming and don't need this check.
  _pw_sourced=1
elif [ -n "$ZSH_EVAL_CONTEXT" ]; then
  case $ZSH_EVAL_CONTEXT in *:file) _pw_sourced=1;; esac
elif [ -n "$KSH_VERSION" ]; then
  [ "$(cd $(dirname -- $0) && pwd -P)/$(basename -- $0)" != \
    "$(cd $(dirname -- ${.sh.file}) && pwd -P)/$(basename -- ${.sh.file})" ] \
    && _pw_sourced=1
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && _pw_sourced=1
else  # All other shells: examine $0 for known shell binary filenames
  # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|dash) _pw_sourced=1;; esac
fi

# Downstream projects need to set something other than PW_ROOT here, like
# YOUR_PROJECT_ROOT. Please also set PW_PROJECT_ROOT and PW_ROOT before
# invoking pw_bootstrap or pw_activate.
######### BEGIN PROJECT-SPECIFIC CODE #########
ZIG2025_DEMO_ROOT="$(_bootstrap_abspath "$(dirname "$_PW_BOOTSTRAP_PATH")")"
export ZIG2025_DEMO_ROOT
PW_PROJECT_ROOT="$ZIG2025_DEMO_ROOT"
PW_ROOT="$ZIG2025_DEMO_ROOT/third_party/pigweed"

# Set your project's banner and color.
PW_BRANDING_BANNER="$ZIG2025_DEMO_ROOT/banner.txt"
export PW_BRANDING_BANNER
PW_BRANDING_BANNER_COLOR=magenta
export PW_BRANDING_BANNER_COLOR

sample_project_banner() {
  cat "$PW_BRANDING_BANNER"
  echo
}

PW_BANNER_FUNC="sample_project_banner"

# Double-check that the Pigweed submodule has been checked out. The file
# checked here is somewhat arbitrary, but should be a file path that is
# relatively stable.
if [ ! -e "$PW_ROOT/pw_env_setup/util.sh" ]; then
  echo "Updating git submodules ..."
  # Init without recursion.
  git -C "$ZIG2025_DEMO_ROOT" submodule update --init
fi

########## END PROJECT-SPECIFIC CODE ##########
export PW_PROJECT_ROOT
export PW_ROOT
if [ -n "$PW_BANNER_FUNC" ]; then
  export PW_BANNER_FUNC
fi

. "$PW_ROOT/pw_env_setup/util.sh"

# Check environment properties
pw_deactivate
pw_eval_sourced "$_pw_sourced" "$_PW_BOOTSTRAP_PATH"
if ! pw_check_root "$PW_ROOT"; then
  return
fi

_PW_ACTUAL_ENVIRONMENT_ROOT="$(pw_get_env_root)"
export _PW_ACTUAL_ENVIRONMENT_ROOT
SETUP_SH="$_PW_ACTUAL_ENVIRONMENT_ROOT/activate.sh"

# Run full bootstrap when invoked as bootstrap, or env file is missing/empty.
if [ "$(basename "$_PW_BOOTSTRAP_PATH")" = "bootstrap.sh" ] || \
  [ ! -f "$SETUP_SH" ] || \
  [ ! -s "$SETUP_SH" ]; then
######### BEGIN PROJECT-SPECIFIC CODE #########
  pw_bootstrap --shell-file "$SETUP_SH" --install-dir "$_PW_ACTUAL_ENVIRONMENT_ROOT" --config-file "$PW_PROJECT_ROOT/pigweed.json"
########## END PROJECT-SPECIFIC CODE ##########
  pw_finalize bootstrap "$SETUP_SH"
else
  pw_activate
  pw_finalize activate "$SETUP_SH"
fi

if [ "$_PW_ENV_SETUP_STATUS" -eq 0 ]; then
# This is where any additional checks about the environment should go.
######### BEGIN PROJECT-SPECIFIC CODE #########
  echo -n
########## END PROJECT-SPECIFIC CODE ##########
fi

unset _pw_sourced
unset _PW_BOOTSTRAP_PATH
unset SETUP_SH
unset _bootstrap_abspath

if [[ "$TERM" != dumb ]]; then
  # Shell completion: bash.
  if test -n "$BASH"; then
    . "$PW_ROOT/pw_cli/py/pw_cli/shell_completion/pw.bash"
    . "$PW_ROOT/pw_cli/py/pw_cli/shell_completion/pw_build.bash"
  # Shell completion: zsh.
  elif test -n "$ZSH_NAME"; then
    . "$PW_ROOT/pw_cli/py/pw_cli/shell_completion/pw.zsh"
    . "$PW_ROOT/pw_cli/py/pw_cli/shell_completion/pw_build.zsh"
  fi
fi

pw_cleanup

git -C "$PW_ROOT" config blame.ignoreRevsFile .git-blame-ignore-revs