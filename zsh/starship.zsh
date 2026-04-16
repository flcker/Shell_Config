################################################################################
# starship
# 随机从submodule/starship/ 目录下的starship配置文件中选取一个，设置为当前的starship配置
STARSHIP_DIR="$ZSH_CONFIG_STARSHIP_DIR"

function __starship_random_config() {
  local files=("$STARSHIP_DIR"/starship*.toml(N-.))
  if (( ${#files} == 0 )); then
    echo ""
    return 0
  fi
  echo "${files[$((RANDOM % ${#files} + 1))]}"
}

export STARSHIP_CONFIG="$(__starship_random_config)"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

################################################################################
# ssc 命令：切换 starship 配置文件
#
# 新增配置：在 STARSHIP_DIR 中放入 starship_<name>.toml，可直接用 ssc <name> 切换
# 新增别名：在 _SSC_ALIASES 中添加一行 <alias> <name>
typeset -gA _SSC_ALIASES=(
  c    custom
  pl   powerline
  npl  nerdpowerline
  ppl  pastelpowerline
  nfs  nerdfontsymbols
  pts  plaintextsymbols
  r    random
)

function __ssc_usage() {
  echo "Current: ${STARSHIP_CONFIG:t:r}"
  echo ""
  echo "Usage: ssc [THEME|-h|--help]"
  echo ""
  echo "Available themes:"
  local f name
  for f in "$STARSHIP_DIR"/starship_*.toml(N-.); do
    name="${${f:t:r}#starship_}"
    echo "  $name"
  done
  echo "  random (default)"
  echo ""
  echo "Aliases:"
  local alias target
  for alias in ${(ko)_SSC_ALIASES}; do
    target="${_SSC_ALIASES[$alias]}"
    echo "  $alias -> $target"
  done
}

function ssc() {
  local input="${1:-random}"

  if [[ "$input" == "-h" || "$input" == "--help" ]]; then
    __ssc_usage
    return 0
  fi

  # 解析别名
  local name="${_SSC_ALIASES[$input]:-$input}"

  if [[ "$name" == "random" ]]; then
    export STARSHIP_CONFIG="$(__starship_random_config)"
    echo "Switched to: ${STARSHIP_CONFIG:t:r}"
    return 0
  fi

  local file="$STARSHIP_DIR/starship_${name}.toml"
  if [[ ! -f "$file" ]]; then
    echo "Unknown theme: $input"
    echo ""
    __ssc_usage
    return 1
  fi

  export STARSHIP_CONFIG="$file"
  echo "Switched to: ${STARSHIP_CONFIG:t:r}"
}
