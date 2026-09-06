#!/usr/bin/env sh
set -eu

ROOT=${PORTABLE_ENV_ROOT:-${ROOT:-}}
PLATFORM=${PORTABLE_ENV_PLATFORM:-${PLATFORM:-}}

if [ -z "$ROOT" ] || [ -z "$PLATFORM" ]; then
  if [ "$#" -ge 2 ]; then
    ROOT=$1
    PLATFORM=$2
  else
    echo "portable-env.sh requires ROOT and PLATFORM."
    return 1 2>/dev/null || exit 1
  fi
fi

PACKAGE_ROOT="$ROOT/packages/$PLATFORM"
NPM_PREFIX="$PACKAGE_ROOT/npm-global"
NPM_CACHE="$PACKAGE_ROOT/npm-cache"
NODE_ROOT="$ROOT/runtime/$PLATFORM"

export OPENCLAW_PORTABLE_ROOT="$ROOT"
export OPENCLAW_PORTABLE_PLATFORM="$PLATFORM"
export OPENCLAW_HOME="$ROOT/data/home"
export OPENCLAW_STATE_DIR="$ROOT/data/openclaw"
export OPENCLAW_CONFIG_PATH="$ROOT/data/config/openclaw.json"
export OPENCLAW_PORTABLE_WORKSPACE="$ROOT/data/workspace"
export HOME="$OPENCLAW_HOME"
export XDG_CONFIG_HOME="$OPENCLAW_HOME/.config"
export XDG_CACHE_HOME="$OPENCLAW_HOME/.cache"
export XDG_STATE_HOME="$OPENCLAW_HOME/.local/state"
export XDG_DATA_HOME="$OPENCLAW_HOME/.local/share"
export TMPDIR="$ROOT/data/temp"
export npm_config_prefix="$NPM_PREFIX"
export npm_config_cache="$NPM_CACHE"
export npm_config_update_notifier=false
export npm_config_fund=false
export npm_config_audit=false
export npm_config_bin_links=false
export PATH="$NODE_ROOT/bin:$NPM_PREFIX/bin:$PATH"

mkdir -p \
  "$OPENCLAW_HOME" \
  "$OPENCLAW_STATE_DIR" \
  "$(dirname "$OPENCLAW_CONFIG_PATH")" \
  "$OPENCLAW_PORTABLE_WORKSPACE" \
  "$XDG_CONFIG_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_STATE_HOME" \
  "$XDG_DATA_HOME" \
  "$TMPDIR" \
  "$NPM_PREFIX" \
  "$NPM_CACHE" \
  "$ROOT/packages/downloads" \
  "$ROOT/logs"

create_config() {
  if [ -f "$ROOT/templates/openclaw.portable.json" ]; then
    sed "s|\${OPENCLAW_PORTABLE_WORKSPACE}|$OPENCLAW_PORTABLE_WORKSPACE|g" \
      "$ROOT/templates/openclaw.portable.json" > "$OPENCLAW_CONFIG_PATH"
  else
    printf '{}\n' > "$OPENCLAW_CONFIG_PATH"
  fi
}

if [ ! -f "$OPENCLAW_CONFIG_PATH" ]; then
  create_config
fi
